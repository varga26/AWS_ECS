module "cw_ecs" {
  source           = "../cloudwatch"
  aws_region       = var.aws_region
  dashboard_name   = "ecs-dashboard"

  alarm_actions = [var.sns_topic_arn]
  alarms = [
    {
      name                = "[llm]-[test]-[ecs]-[high]-[cpu]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CpuUtilized"
      namespace           = "ECS/ContainerInsights"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      description         = "High CPU"
      dimensions          = { ClusterName = var.ecs_cluster_name, ContainerName = "ollama", TaskDefinitionFamily = "ollama" }
    },
    {
      name                = "[llm]-[test]-[ecs]-[high]-[memory]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "MemoryUtilized"
      namespace           = "ECS/ContainerInsights"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      description         = "High memory usage"
      dimensions          = { ClusterName = var.ecs_cluster_name, ContainerName = "ollama", TaskDefinitionFamily = "ollama" }
    }
  ]

  widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 12
      height = 6
      properties = {
        metrics = [
          [{ "expression": "SEARCH('{ECS/ContainerInsights,ClusterName,TaskDefinitionFamily,ContainerName} MetricName=\"CpuUtilized\" ClusterName=\"${var.ecs_cluster_name}\"', 'Average', 60)", "id": "e1" }]
        ]
        period  = 60
        stat    = "Average"
        region  = var.aws_region
        title   = "ECS Containers CPU Utilization"
        view    = "timeSeries"
        stacked = false
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 0
      width  = 12
      height = 6
      properties = {
        metrics = [
          [{ "expression": "SEARCH('{ECS/ContainerInsights,ClusterName,TaskDefinitionFamily,ContainerName} MetricName=\"MemoryUtilized\" ClusterName=\"${var.ecs_cluster_name}\"', 'Average', 60)", "id": "e1" }]
        ]
        period  = 60
        stat    = "Average"
        region  = var.aws_region
        title   = "ECS Containers Memory Utilization"
        view    = "timeSeries"
        stacked = false
      }
    }
  ]
}

module "cw_rds" {
  source           = "../cloudwatch"
  aws_region     = var.aws_region
  dashboard_name = "rds-dashboard"

  alarm_actions = [var.sns_topic_arn]
  alarms = [
    {
      name                = "[llm]-[test]-[db]-[high]-[cpu]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/RDS"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      description         = "High CPU Utilization"
      dimensions          = { DBInstanceIdentifier = var.rds_identifier }
    },
    {
      name                = "[llm]-[test]-[db]-[high]-[memory]"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "FreeableMemory"
      namespace           = "AWS/RDS"
      period              = 300
      statistic           = "Average"
      threshold           = 268435456 # 256MB
      description         = "High memory usage (low freeable memory)"
      dimensions          = { DBInstanceIdentifier = var.rds_identifier }
    },
    {
      name                = "[llm]-[test]-[db]-[high]-[storage]"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "FreeStorageSpace"
      namespace           = "AWS/RDS"
      period              = 300
      statistic           = "Average"
      threshold           = 2147483648 # 2GB
      description         = "High storage usage (low free storage)"
      dimensions          = { DBInstanceIdentifier = var.rds_identifier }
    }
  ]

  widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_identifier]]
        period  = 300
        stat    = "Average"
        region  = var.aws_region
        title   = "RDS CPU Utilization"
      }
    },
    {
      type   = "metric"
      x      = 8
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", var.rds_identifier]]
        period  = 300
        stat    = "Average"
        region  = var.aws_region
        title   = "RDS Freeable Memory"
      }
    },
    {
      type   = "metric"
      x      = 16
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_identifier]]
        period  = 300
        stat    = "Average"
        region  = var.aws_region
        title   = "RDS Free Storage Space"
      }
    }
  ]
}

module "cw_elb" {
  source           = "../cloudwatch"
  aws_region     = var.aws_region
  dashboard_name = "elb-dashboard"

  alarm_actions = [var.sns_topic_arn]
  alarms = [
    {
      name                = "[llm]-[test]-[elb]-[high]-[host-count]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "HealthyHostCount"
      namespace           = "AWS/ApplicationELB"
      period              = 300
      statistic           = "Average"
      threshold           = 5
      description         = "Too many healthy hosts"
      dimensions          = { LoadBalancer = var.alb_arn_suffix, TargetGroup = var.target_group_arn_suffix }
    },
    {
      name                = "[llm]-[test]-[elb]-[medium]-[4XX-errors]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "HTTPCode_Target_4XX_Count"
      namespace           = "AWS/ApplicationELB"
      period              = 300
      statistic           = "Sum"
      threshold           = 50
      description         = "Elevated 4XX errors"
      dimensions          = { LoadBalancer = var.alb_arn_suffix }
    },
    {
      name                = "[llm]-[test]-[elb]-[medium]-[5XX-errors]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "HTTPCode_Target_5XX_Count"
      namespace           = "AWS/ApplicationELB"
      period              = 300
      statistic           = "Sum"
      threshold           = 10
      description         = "Elevated 5XX errors"
      dimensions          = { LoadBalancer = var.alb_arn_suffix }
    }
  ]

  widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix]]
        period  = 60
        stat    = "Average"
        region  = var.aws_region
        title   = "ALB Healthy Hosts (OpenWebUI)"
        view    = "timeSeries"
        stacked = false
      }
    },
    {
      type   = "metric"
      x      = 8
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix],
        ]
        period  = 60
        stat    = "Sum"
        region  = var.aws_region
        title   = "ALB Request Count"
        view    = "timeSeries"
        stacked = false
      }
    },
    {
      type   = "metric"
      x      = 16
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix],
        ]
        period  = 60
        stat    = "Average"
        region  = var.aws_region
        title   = "ALB Target Response Time (s)"
        view    = "timeSeries"
        stacked = false
      }
    },
    {
      type   = "metric"
      x      = 0
      y      = 6
      width  = 12
      height = 6
      properties = {
        metrics = [
          ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", var.alb_arn_suffix],
          ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix],
        ]
        period  = 60
        stat    = "Sum"
        region  = var.aws_region
        title   = "ALB 4XX / 5XX Error Count"
        view    = "timeSeries"
        stacked = false
      }
    }
  ]
}
