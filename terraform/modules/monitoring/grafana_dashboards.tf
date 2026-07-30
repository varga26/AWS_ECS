resource "null_resource" "wait_for_grafana" {
  provisioner "local-exec" {
    command = "for i in {1..45}; do if [ \"$(curl -s -o /dev/null -w '%%{http_code}' http://${var.alb_dns_name}/grafana/api/health)\" = \"200\" ]; then echo 'Grafana is ready!'; break; else echo 'Waiting for Grafana...'; sleep 10; fi; done"
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

resource "grafana_dashboard" "hosts" {
  folder = grafana_folder.llm_monitoring.id
  config_json = templatefile("${path.module}/dashboards/ECS.json", {
    cloudwatch_uid   = grafana_data_source.cloudwatch.uid
    prometheus_uid   = grafana_data_source.prometheus.uid
    ecs_cluster_name = var.ecs_cluster_name
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
