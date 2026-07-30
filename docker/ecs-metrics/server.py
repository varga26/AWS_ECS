#!/usr/bin/env python3
"""
ECS Task Metadata Exporter
Reads $ECS_CONTAINER_METADATA_URI_V4/task/stats and exposes Prometheus metrics
with container_name, task_family, az, and cluster labels.
Port: 9091 (configurable via METRICS_PORT env var)
"""
import json
import os
import urllib.request
from http.server import BaseHTTPRequestHandler, HTTPServer

METADATA_URI = os.environ.get("ECS_CONTAINER_METADATA_URI_V4", "")
PORT = int(os.environ.get("METRICS_PORT", "9091"))


def fetch_json(url: str) -> dict:
    with urllib.request.urlopen(url, timeout=5) as resp:
        return json.loads(resp.read())


def cpu_percent(stats: dict) -> float:
    """Calculate CPU utilization % from Docker stats delta."""
    try:
        cpu_delta = (
            stats["cpu_stats"]["cpu_usage"]["total_usage"]
            - stats["precpu_stats"]["cpu_usage"]["total_usage"]
        )
        sys_delta = (
            stats["cpu_stats"]["system_cpu_usage"]
            - stats["precpu_stats"]["system_cpu_usage"]
        )
        num_cpus = stats["cpu_stats"].get("online_cpus", 1)
        if sys_delta > 0 and cpu_delta >= 0:
            return (cpu_delta / sys_delta) * num_cpus * 100.0
    except (KeyError, TypeError, ZeroDivisionError):
        pass
    return 0.0


def build_metrics() -> str:
    task_meta = fetch_json(f"{METADATA_URI}/task")
    task_stats = fetch_json(f"{METADATA_URI}/task/stats")

    # Cluster may be a full ARN — extract just the name
    cluster_raw = task_meta.get("Cluster", "unknown")
    cluster = cluster_raw.rsplit("/", 1)[-1]
    az = task_meta.get("AvailabilityZone", "unknown")
    task_family = task_meta.get("Family", "unknown")

    lines = [
        "# HELP ecs_container_cpu_utilized CPU utilization percentage per container",
        "# TYPE ecs_container_cpu_utilized gauge",
        "# HELP ecs_container_memory_utilized_bytes Memory usage in bytes per container",
        "# TYPE ecs_container_memory_utilized_bytes gauge",
        "# HELP ecs_container_memory_limit_bytes Memory limit in bytes per container",
        "# TYPE ecs_container_memory_limit_bytes gauge",
    ]

    for _container_id, stats in task_stats.items():
        name = stats.get("name", _container_id).lstrip("/")
        labels = (
            f'container_name="{name}",'
            f'task_family="{task_family}",'
            f'az="{az}",'
            f'cluster="{cluster}"'
        )
        cpu = cpu_percent(stats)
        mem_usage = stats.get("memory_stats", {}).get("usage", 0)
        mem_limit = stats.get("memory_stats", {}).get("limit", 0)

        lines.append(f"ecs_container_cpu_utilized{{{labels}}} {cpu:.4f}")
        lines.append(f"ecs_container_memory_utilized_bytes{{{labels}}} {mem_usage}")
        lines.append(f"ecs_container_memory_limit_bytes{{{labels}}} {mem_limit}")

    return "\n".join(lines) + "\n"


class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/metrics":
            self.send_response(404)
            self.end_headers()
            return
        try:
            body = build_metrics().encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        except Exception as exc:
            body = f"Error: {exc}".encode("utf-8")
            self.send_response(500)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass  # suppress per-request access logs


if __name__ == "__main__":
    if not METADATA_URI:
        print("WARNING: ECS_CONTAINER_METADATA_URI_V4 is not set — running outside Fargate?")
    server = HTTPServer(("0.0.0.0", PORT), MetricsHandler)
    print(f"ECS metrics exporter listening on :{PORT}/metrics")
    server.serve_forever()
