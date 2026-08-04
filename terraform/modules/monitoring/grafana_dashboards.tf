resource "null_resource" "wait_for_grafana" {
  triggers = {
    alb_dns_name = var.alb_dns_name
    timestamp    = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      READY=0
      for i in $(seq 1 60); do
        STATUS=$(curl -s -o /dev/null -w '%%{http_code}' http://${var.alb_dns_name}/grafana/api/health || true)
        if [ "$STATUS" = "200" ]; then
          echo "Grafana is ready!"
          READY=1
          break
        else
          echo "Waiting for Grafana (attempt $i/60, status: $STATUS)..."
          sleep 5
        fi
      done

      if [ "$READY" -ne 1 ]; then
        echo "Error: Grafana failed to become ready in time"
        exit 1
      fi
    EOT
  }
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "Prometheus"
  url        = "http://${var.alb_dns_name}/prometheus"
  is_default = true
  depends_on = [null_resource.wait_for_grafana]
}

resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch"
  name = "CloudWatch"
  json_data_encoded = jsonencode({
    authType      = "default"
    defaultRegion = "us-east-1"
  })
  depends_on = [null_resource.wait_for_grafana]
}

resource "grafana_folder" "llm_monitoring" {
  title      = "LLM Observability"
  depends_on = [null_resource.wait_for_grafana]
}

resource "grafana_folder" "ecs_logs" {
  title      = "ECS Logs"
  depends_on = [null_resource.wait_for_grafana]
}


resource "grafana_dashboard" "aws_infrastructure" {
  folder = grafana_folder.llm_monitoring.id
  config_json = templatefile("${path.module}/dashboards/aws_infrastructure.json", {
    cloudwatch_uid                    = grafana_data_source.cloudwatch.uid
    rds_identifier                    = var.rds_identifier
    alb_arn_suffix                    = var.alb_arn_suffix
    openwebui_target_group_arn_suffix = var.target_group_arn_suffix
    ollama_lb_arn_suffix              = var.ollama_lb_arn_suffix
    ollama_target_group_arn_suffix    = var.ollama_target_group_arn_suffix
  })
  depends_on = [grafana_data_source.cloudwatch]
}

resource "grafana_dashboard" "hosts_ollama" {
  folder = grafana_folder.llm_monitoring.id
  config_json = templatefile("${path.module}/dashboards/ECS.json", {
    cloudwatch_uid   = grafana_data_source.cloudwatch.uid
    prometheus_uid   = grafana_data_source.prometheus.uid
    ecs_cluster_name = var.ecs_cluster_name
    service_name     = "ollama"
    dashboard_title  = "Ollama CPU & Memory"
  })
  depends_on = [grafana_data_source.cloudwatch, grafana_data_source.prometheus]
}

resource "grafana_dashboard" "hosts_openwebui" {
  folder = grafana_folder.llm_monitoring.id
  config_json = templatefile("${path.module}/dashboards/ECS.json", {
    cloudwatch_uid   = grafana_data_source.cloudwatch.uid
    prometheus_uid   = grafana_data_source.prometheus.uid
    ecs_cluster_name = var.ecs_cluster_name
    service_name     = "openwebui"
    dashboard_title  = "OpenWebUI CPU & Memory"
  })
  depends_on = [grafana_data_source.cloudwatch, grafana_data_source.prometheus]
}

resource "grafana_dashboard" "hosts_prometheus" {
  folder = grafana_folder.llm_monitoring.id
  config_json = templatefile("${path.module}/dashboards/ECS.json", {
    cloudwatch_uid   = grafana_data_source.cloudwatch.uid
    prometheus_uid   = grafana_data_source.prometheus.uid
    ecs_cluster_name = var.ecs_cluster_name
    service_name     = "prometheus"
    dashboard_title  = "Prometheus CPU & Memory"
  })
  depends_on = [grafana_data_source.cloudwatch, grafana_data_source.prometheus]
}

resource "grafana_dashboard" "hosts_grafana" {
  folder = grafana_folder.llm_monitoring.id
  config_json = templatefile("${path.module}/dashboards/ECS.json", {
    cloudwatch_uid   = grafana_data_source.cloudwatch.uid
    prometheus_uid   = grafana_data_source.prometheus.uid
    ecs_cluster_name = var.ecs_cluster_name
    service_name     = "grafana"
    dashboard_title  = "Grafana CPU & Memory"
  })
  depends_on = [grafana_data_source.cloudwatch, grafana_data_source.prometheus]
}

resource "grafana_dashboard" "llm_performance" {
  folder = grafana_folder.llm_monitoring.id
  config_json = templatefile("${path.module}/dashboards/llm_performance.json", {
    prometheus_uid = grafana_data_source.prometheus.uid
  })
  depends_on = [grafana_data_source.prometheus]
}

resource "grafana_dashboard" "openwebui_usage" {
  folder = grafana_folder.llm_monitoring.id
  config_json = templatefile("${path.module}/dashboards/openwebui_usage.json", {
    prometheus_uid = grafana_data_source.prometheus.uid
  })
  depends_on = [grafana_data_source.prometheus]
}

resource "grafana_dashboard" "application_logs" {
  folder = grafana_folder.ecs_logs.id
  config_json = templatefile("${path.module}/Logs/container_logs.json", {
    cloudwatch_uid = grafana_data_source.cloudwatch.uid
  })
  depends_on = [grafana_data_source.cloudwatch]
}
