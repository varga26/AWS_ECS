

resource "grafana_rule_group" "rds_alerts" {
  name             = "RDS Alerts"
  folder_uid       = grafana_folder.llm_monitoring.uid
  interval_seconds = 60
  org_id           = 1

  rule {
    name           = "[llm]-[test]-[db]-[high]-[cpu]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/RDS"
        metricName = "CPUUtilization"
        dimensions = {
          DBInstanceIdentifier = var.rds_identifier
        }
        statistic        = "Average"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [80], type = "gt" }
            operator  = { type = "and" }
            query     = { params = ["A"] }
            reducer   = { params = [], type = "last" }
            type      = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId      = "B"
        type       = "classic_conditions"
      })
    }
  }

  rule {
    name           = "[llm]-[test]-[db]-[low]-[storage]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/RDS"
        metricName = "FreeStorageSpace"
        dimensions = {
          DBInstanceIdentifier = var.rds_identifier
        }
        statistic        = "Average"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [5000000000], type = "lt" } # 5 GB
            operator  = { type = "and" }
            query     = { params = ["A"] }
            reducer   = { params = [], type = "last" }
            type      = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId      = "B"
        type       = "classic_conditions"
      })
    }
  }
}

resource "grafana_rule_group" "elb_alerts" {
  name             = "ELB Alerts"
  folder_uid       = grafana_folder.llm_monitoring.uid
  interval_seconds = 60
  org_id           = 1

  rule {
    name           = "[llm]-[test]-[elb]-[medium]-[5XX-errors]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/ApplicationELB"
        metricName = "HTTPCode_Target_5XX_Count"
        dimensions = {
          LoadBalancer = var.alb_arn_suffix
        }
        statistic        = "Sum"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [10], type = "gt" }
            operator  = { type = "and" }
            query     = { params = ["A"] }
            reducer   = { params = [], type = "last" }
            type      = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId      = "B"
        type       = "classic_conditions"
      })
    }
  }

  rule {
    name           = "[llm]-[test]-[openwebui]-[low]-[healthy-hosts]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/ApplicationELB"
        metricName = "HealthyHostCount"
        dimensions = {
          LoadBalancer = var.alb_arn_suffix
          TargetGroup  = var.target_group_arn_suffix
        }
        statistic        = "Average"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [2], type = "lt" }
            operator  = { type = "and" }
            query     = { params = ["A"] }
            reducer   = { params = [], type = "last" }
            type      = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId      = "B"
        type       = "classic_conditions"
      })
    }
  }

  rule {
    name           = "[llm]-[test]-[ollama]-[low]-[healthy-hosts]"
    condition      = "B"
    for            = "1m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/ApplicationELB"
        metricName = "HealthyHostCount"
        dimensions = {
          LoadBalancer = var.ollama_lb_arn_suffix
          TargetGroup  = var.ollama_target_group_arn_suffix
        }
        statistic        = "Average"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [4], type = "lt" }
            operator  = { type = "and" }
            query     = { params = ["A"] }
            reducer   = { params = [], type = "last" }
            type      = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId      = "B"
        type       = "classic_conditions"
      })
    }
  }
}


resource "grafana_rule_group" "container_alerts" {
  name             = "Container Alerts"
  folder_uid       = grafana_folder.llm_monitoring.uid
  interval_seconds = 60
  org_id           = 1

  rule {
    name           = "[llm]-[test]-[container]-[high]-[cpu]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/ECS"
        metricName = "CPUUtilization"
        dimensions = {
          ClusterName = var.ecs_cluster_name
          ServiceName = var.ollama_service_name
        }
        statistic        = "Average"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [85], type = "gt" }
            operator  = { type = "and" }
            query     = { params = ["A"] }
            reducer   = { params = [], type = "last" }
            type      = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId      = "B"
        type       = "classic_conditions"
      })
    }
  }

  rule {
    name           = "[llm]-[test]-[container]-[high]-[memory]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.cloudwatch.uid
      model = jsonencode({
        region     = "default"
        namespace  = "AWS/ECS"
        metricName = "MemoryUtilization"
        dimensions = {
          ClusterName = var.ecs_cluster_name
          ServiceName = var.ollama_service_name
        }
        statistic        = "Average"
        period           = "300"
        matchExact       = false
        metricQueryType  = 0
        metricEditorMode = 0
        refId            = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [85], type = "gt" }
            operator  = { type = "and" }
            query     = { params = ["A"] }
            reducer   = { params = [], type = "last" }
            type      = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId      = "B"
        type       = "classic_conditions"
      })
    }
  }
}

resource "grafana_rule_group" "llm_alerts" {
  name             = "LLM Alerts"
  folder_uid       = grafana_folder.llm_monitoring.uid
  interval_seconds = 60
  org_id           = 1

  rule {
    name           = "[llm]-[test]-[ollama]-[high]-[queue]"
    condition      = "B"
    for            = "5m"
    exec_err_state = "Alerting"
    no_data_state  = "NoData"

    data {
      ref_id = "A"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = grafana_data_source.prometheus.uid
      model = jsonencode({
        expr  = "ollama_queue_size"
        refId = "A"
      })
    }
    data {
      ref_id = "B"
      relative_time_range {
        from = 300
        to   = 0
      }
      datasource_uid = "-100"
      model = jsonencode({
        conditions = [
          {
            evaluator = { params = [5], type = "gt" }
            operator  = { type = "and" }
            query     = { params = ["A"] }
            reducer   = { params = [], type = "last" }
            type      = "query"
          }
        ]
        datasource = { type = "__expr__", uid = "-100" }
        refId      = "B"
        type       = "classic_conditions"
      })
    }
  }
}


resource "grafana_message_template" "llm_alert" {
  name     = "llm-alert-template"
  template = <<-EOT
    {{ define "llm-alert-title" }}
    [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .GroupLabels.alertname }}
    {{ end }}

    {{ define "llm-alert-body" }}
    {{ if gt (len .Alerts.Firing) 0 }}
    🔴 *Firing Alerts ({{ .Alerts.Firing | len }})*
    {{ range .Alerts.Firing }}
    • *{{ .Labels.alertname }}*
      Summary: {{ if .Annotations.summary }}{{ .Annotations.summary }}{{ else }}No summary{{ end }}
      Started: {{ .StartsAt }}
    {{ end }}
    {{ end }}
    {{ if gt (len .Alerts.Resolved) 0 }}
    ✅ *Resolved Alerts ({{ .Alerts.Resolved | len }})*
    {{ range .Alerts.Resolved }}
    • *{{ .Labels.alertname }}* — resolved at {{ .EndsAt }}
    {{ end }}
    {{ end }}
    {{ end }}
  EOT

  depends_on = [null_resource.wait_for_grafana]
}

resource "grafana_contact_point" "email" {
  name = "Email"

  email {
    addresses               = [var.endpoint]
    message                 = "{{ template \"llm-alert-body\" . }}"
    single_email            = false
    disable_resolve_message = false
  }

  depends_on = [null_resource.wait_for_grafana]
}

resource "grafana_contact_point" "slack" {
  count = var.slack_webhook_url != "" ? 1 : 0
  name  = "Slack"

  slack {
    url                     = var.slack_webhook_url
    title                   = "{{ template \"llm-alert-title\" . }}"
    text                    = "{{ template \"llm-alert-body\" . }}"
    username                = "Grafana Alertmanager"
    icon_emoji              = ":grafana:"
    disable_resolve_message = false
  }

  depends_on = [null_resource.wait_for_grafana]
}

resource "grafana_contact_point" "pagerduty" {
  count = var.pagerduty_integration_key != "" ? 1 : 0
  name  = "PagerDuty"

  pagerduty {
    integration_key         = var.pagerduty_integration_key
    severity                = "critical"
    class                   = "LLM Platform"
    component               = "ollama-openwebui"
    group                   = "llm-monitoring"
    summary                 = "{{ template \"llm-alert-title\" . }}"
    disable_resolve_message = false
  }

  depends_on = [null_resource.wait_for_grafana]
}

resource "grafana_notification_policy" "main" {
  group_by      = ["alertname", "grafana_folder"]
  contact_point = grafana_contact_point.email.name

  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "1h"

  # Email
  policy {
    group_by      = ["alertname"]
    contact_point = grafana_contact_point.email.name
    continue      = true
    matcher {
      label = "grafana_folder"
      match = "="
      value = "LLM Monitoring"
    }
    group_wait      = "30s"
    group_interval  = "5m"
    repeat_interval = "1h"
  }

  dynamic "policy" {
    for_each = var.slack_webhook_url != "" ? [1] : []
    content {
      group_by      = ["alertname"]
      contact_point = grafana_contact_point.slack[0].name
      continue      = true
      matcher {
        label = "grafana_folder"
        match = "="
        value = "LLM Monitoring"
      }
      group_wait      = "30s"
      group_interval  = "5m"
      repeat_interval = "1h"
    }
  }

  dynamic "policy" {
    for_each = var.pagerduty_integration_key != "" ? [1] : []
    content {
      group_by      = ["alertname"]
      contact_point = grafana_contact_point.pagerduty[0].name
      continue      = true
      matcher {
        label = "grafana_folder"
        match = "="
        value = "LLM Monitoring"
      }
      group_wait      = "30s"
      group_interval  = "5m"
      repeat_interval = "4h"
    }
  }


  depends_on = [
    grafana_contact_point.email,
    grafana_contact_point.slack,
    grafana_contact_point.pagerduty,
  ]
}

