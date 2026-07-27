
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
