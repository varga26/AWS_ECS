resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = var.container_definitions

  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value.name

      dynamic "efs_volume_configuration" {
        for_each = lookup(volume.value, "efs_volume_configuration", null) != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id     = efs_volume_configuration.value.file_system_id
          transit_encryption = lookup(efs_volume_configuration.value, "transit_encryption", "ENABLED")

          dynamic "authorization_config" {
            for_each = lookup(efs_volume_configuration.value, "authorization_config", null) != null ? [efs_volume_configuration.value.authorization_config] : []
            content {
              access_point_id = lookup(authorization_config.value, "access_point_id", null)
              iam             = lookup(authorization_config.value, "iam", "ENABLED")
            }
          }
        }
      }
    }
  }
}

resource "aws_ecs_service" "this" {
  name                 = var.service_name != null ? var.service_name : "${var.family}-service"
  cluster              = var.cluster_id
  task_definition      = aws_ecs_task_definition.this.arn
  desired_count        = var.desired_count
  launch_type          = var.launch_type
  force_new_deployment = var.force_new_deployment

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null && var.target_group_arn != "" ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name != null ? var.container_name : var.family
      container_port   = var.container_port
    }
  }

  dynamic "service_registries" {
    for_each = var.service_discovery_namespace_id != null && var.service_discovery_namespace_id != "" ? [1] : []
    content {
      registry_arn = aws_service_discovery_service.this[0].arn
    }
  }
}

resource "aws_service_discovery_service" "this" {
  count = var.service_discovery_namespace_id != null && var.service_discovery_namespace_id != "" ? 1 : 0
  name  = var.service_discovery_name != null ? var.service_discovery_name : var.family

  dns_config {
    namespace_id = var.service_discovery_namespace_id
    dns_records {
      ttl  = var.service_discovery_dns_ttl
      type = "A"
    }
  }
}
