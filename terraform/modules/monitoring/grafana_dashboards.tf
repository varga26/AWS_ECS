resource "null_resource" "wait_for_grafana" {
  provisioner "local-exec" {
    command = "for i in {1..30}; do curl -s --connect-timeout 2 http://${var.alb_dns_name}/grafana/api/health && break || sleep 10; done"
  }
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "Prometheus"
  url        = "http://localhost:9090"
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
  title      = "LLM Monitoring"
  depends_on = [null_resource.wait_for_grafana]
}

resource "grafana_dashboard" "hosts" {
  folder      = grafana_folder.llm_monitoring.id
  config_json = file("${path.module}/dashboards/hosts.json")
  depends_on  = [grafana_data_source.prometheus]
}

resource "grafana_dashboard" "services" {
  folder = grafana_folder.llm_monitoring.id
  config_json = templatefile("${path.module}/dashboards/services.json", {
    cloudwatch_uid                    = grafana_data_source.cloudwatch.uid
    rds_identifier                    = var.rds_identifier
    alb_arn_suffix                    = var.alb_arn_suffix
    openwebui_target_group_arn_suffix = var.target_group_arn_suffix
    ollama_lb_arn_suffix              = var.ollama_lb_arn_suffix
    ollama_target_group_arn_suffix    = var.ollama_target_group_arn_suffix
  })
  depends_on = [grafana_data_source.cloudwatch]
}

resource "grafana_dashboard" "alb" {
  folder = grafana_folder.llm_monitoring.id
  config_json = templatefile("${path.module}/dashboards/alb.json", {
    cloudwatch_uid          = grafana_data_source.cloudwatch.uid
    alb_arn_suffix          = var.alb_arn_suffix
    target_group_arn_suffix = var.target_group_arn_suffix
  })
  depends_on = [grafana_data_source.cloudwatch]
}

resource "grafana_dashboard" "rds" {
  folder = grafana_folder.llm_monitoring.id
  config_json = templatefile("${path.module}/dashboards/rds.json", {
    cloudwatch_uid = grafana_data_source.cloudwatch.uid
    rds_identifier = var.rds_identifier
  })
  depends_on = [grafana_data_source.cloudwatch]
}



