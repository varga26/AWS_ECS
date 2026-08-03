
moved {
  from = module.cw_ollama
  to   = module.monitoring.module.cw_ollama
}

moved {
  from = module.cw_rds
  to   = module.monitoring.module.cw_rds
}

moved {
  from = module.cw_elb
  to   = module.monitoring.module.cw_elb
}

# Grafana Core
moved {
  from = null_resource.wait_for_grafana
  to   = module.monitoring.null_resource.wait_for_grafana
}

moved {
  from = grafana_data_source.prometheus
  to   = module.monitoring.grafana_data_source.prometheus
}

moved {
  from = grafana_data_source.cloudwatch
  to   = module.monitoring.grafana_data_source.cloudwatch
}

moved {
  from = grafana_folder.llm_monitoring
  to   = module.monitoring.grafana_folder.llm_monitoring
}

# Dashboards
moved {
  from = grafana_dashboard.hosts
  to   = module.monitoring.grafana_dashboard.hosts
}

moved {
  from = grafana_dashboard.services
  to   = module.monitoring.grafana_dashboard.services
}

moved {
  from = grafana_dashboard.asg
  to   = module.monitoring.grafana_dashboard.asg
}

moved {
  from = grafana_dashboard.alb
  to   = module.monitoring.grafana_dashboard.alb
}

moved {
  from = grafana_dashboard.rds
  to   = module.monitoring.grafana_dashboard.rds
}

# Alerting
moved {
  from = grafana_rule_group.ec2_alerts
  to   = module.monitoring.grafana_rule_group.ec2_alerts
}

moved {
  from = grafana_rule_group.rds_alerts
  to   = module.monitoring.grafana_rule_group.rds_alerts
}

moved {
  from = grafana_rule_group.elb_alerts
  to   = module.monitoring.grafana_rule_group.elb_alerts
}

moved {
  from = grafana_message_template.llm_alert
  to   = module.monitoring.grafana_message_template.llm_alert
}

moved {
  from = grafana_contact_point.email
  to   = module.monitoring.grafana_contact_point.email
}

moved {
  from = grafana_contact_point.slack
  to   = module.monitoring.grafana_contact_point.slack
}

moved {
  from = grafana_contact_point.pagerduty
  to   = module.monitoring.grafana_contact_point.pagerduty
}

moved {
  from = grafana_notification_policy.main
  to   = module.monitoring.grafana_notification_policy.main
}

# ECS Cluster and Shared Resources
moved {
  from = module.ecs.aws_ecs_cluster.main
  to   = module.ecs_cluster.aws_ecs_cluster.main
}

moved {
  from = module.ecs.aws_ecs_cluster_capacity_providers.main
  to   = module.ecs_cluster.aws_ecs_cluster_capacity_providers.main
}

moved {
  from = module.ecs.aws_cloudwatch_log_group.ecs_logs
  to   = module.ecs_cluster.aws_cloudwatch_log_group.ecs_logs
}

moved {
  from = module.ecs.aws_service_discovery_private_dns_namespace.main
  to   = module.ecs_cluster.aws_service_discovery_private_dns_namespace.main
}

moved {
  from = module.ecs.aws_iam_role.ecs_execution_role
  to   = module.ecs_cluster.aws_iam_role.ecs_execution_role
}

moved {
  from = module.ecs.aws_iam_role_policy_attachment.ecs_execution_role_policy
  to   = module.ecs_cluster.aws_iam_role_policy_attachment.ecs_execution_role_policy
}

moved {
  from = module.ecs.aws_iam_role_policy.ecs_execution_efs_policy
  to   = module.ecs_cluster.aws_iam_role_policy.ecs_execution_efs_policy
}

moved {
  from = module.ecs.aws_iam_role.ecs_task_role
  to   = module.ecs_cluster.aws_iam_role.ecs_task_role
}

moved {
  from = module.ecs.aws_iam_role_policy.ecs_task_policy
  to   = module.ecs_cluster.aws_iam_role_policy.ecs_task_policy
}

moved {
  from = module.ecs.aws_iam_role_policy_attachment.ecs_task_cloudwatch
  to   = module.ecs_cluster.aws_iam_role_policy_attachment.ecs_task_cloudwatch
}

# ECS Ollama Service
moved {
  from = module.ecs.aws_ecs_task_definition.ollama
  to   = module.ecs_ollama.aws_ecs_task_definition.this
}

moved {
  from = module.ecs.aws_ecs_service.ollama
  to   = module.ecs_ollama.aws_ecs_service.this
}

moved {
  from = module.ecs.aws_service_discovery_service.ollama
  to   = module.ecs_ollama.aws_service_discovery_service.this[0]
}

# ECS OpenWebUI Service
moved {
  from = module.ecs.aws_ecs_task_definition.openwebui
  to   = module.ecs_openwebui.aws_ecs_task_definition.this
}

moved {
  from = module.ecs.aws_ecs_service.openwebui
  to   = module.ecs_openwebui.aws_ecs_service.this
}

moved {
  from = module.ecs.aws_service_discovery_service.openwebui
  to   = module.ecs_openwebui.aws_service_discovery_service.this[0]
}

# ECS Prometheus Service
moved {
  from = module.ecs.aws_ecs_task_definition.prometheus
  to   = module.ecs_prometheus.aws_ecs_task_definition.this
}

moved {
  from = module.ecs.aws_ecs_service.prometheus
  to   = module.ecs_prometheus.aws_ecs_service.this
}

moved {
  from = module.ecs.aws_service_discovery_service.prometheus
  to   = module.ecs_prometheus.aws_service_discovery_service.this[0]
}

# ECS Grafana Service
moved {
  from = module.ecs.aws_ecs_task_definition.grafana
  to   = module.ecs_grafana.aws_ecs_task_definition.this
}

moved {
  from = module.ecs.aws_ecs_service.grafana
  to   = module.ecs_grafana.aws_ecs_service.this
}

moved {
  from = module.ecs.aws_service_discovery_service.grafana
  to   = module.ecs_grafana.aws_service_discovery_service.this[0]
}
