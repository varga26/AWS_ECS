module "network" {
  source                    = "./modules/network"
  vpc_cidr                  = var.vpc_cidr
  private_subnet_1_az_cidr  = var.private_subnet_1_az_cidr
  private_subnet_2_az_cidr  = var.private_subnet_2_az_cidr
  private_subnet_1_rds_cidr = var.private_subnet_1_rds_cidr
  private_subnet_2_rds_cidr = var.private_subnet_2_rds_cidr
  public_subnet_1_cidr      = var.public_subnet_1_cidr
  public_subnet_2_cidr      = var.public_subnet_2_cidr
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
}

module "db" {
  source                  = "./modules/db"
  rds_sg_id               = module.security.rds_sg_id
  private_subnet_1_rds_id = module.network.private_subnet_1_rds_id
  private_subnet_2_rds_id = module.network.private_subnet_2_rds_id
  allocated_storage       = var.db_allocated_storage
  db_name                 = var.db_name
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  parameter_group_name    = var.db_parameter_group_name
  db_username             = var.db_username
  db_password             = var.db_password
}

module "lb" {
  source              = "./modules/lb"
  lb_sg_id            = module.security.lb_sg_id
  public_subnet_1_id  = module.network.public_subnet_1_id
  public_subnet_2_id  = module.network.public_subnet_2_id
  private_subnet_1_id = module.network.private_subnet_1_az_id
  private_subnet_2_id = module.network.private_subnet_2_az_id
  vpc_id              = module.network.vpc_id
}

module "ecr" {
  source = "./modules/ecr"
}

module "storage" {
  source     = "./modules/storage"
  subnet_ids = [module.network.private_subnet_1_az_id, module.network.private_subnet_2_az_id]
  efs_sg_id  = module.security.efs_sg_id
}

module "ecs_cluster" {
  source = "./modules/ecs_cluster"
  vpc_id = module.network.vpc_id
}

locals {
  adot_container = {
    name      = "aws-otel-collector"
    image     = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
    essential = false
    portMappings = [{ containerPort = 20000, hostPort = 20000, protocol = "tcp" }]
    environment = [
      {
        name = "AOT_CONFIG_CONTENT"
        value = yamlencode({
          receivers = {
            awsecscontainermetrics = {
              collection_interval = "20s"
            }
          }
          processors = {
            resourcedetection = {
              detectors = ["env", "ecs"]
              timeout   = "2s"
              override  = false
            }
          }
          exporters = {
            prometheus = {
              endpoint = "0.0.0.0:20000"
              resource_to_telemetry_conversion = {
                enabled = true
              }
            }
          }
          service = {
            pipelines = {
              metrics = {
                receivers  = ["awsecscontainermetrics"]
                processors = ["resourcedetection"]
                exporters  = ["prometheus"]
              }
            }
          }
        })
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = module.ecs_cluster.log_group_name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "adot"
      }
    }
  }
}

module "ecs_ollama" {
  source             = "./modules/ecs"
  family             = "ollama"
  cluster_id         = module.ecs_cluster.cluster_id
  cpu                = var.ollama_cpu
  memory             = var.ollama_memory
  desired_count      = var.ollama_desired_count
  subnet_ids         = [module.network.private_subnet_1_az_id, module.network.private_subnet_2_az_id]
  security_group_ids = [module.security.ecs_sg_id]
  execution_role_arn = module.ecs_cluster.execution_role_arn
  task_role_arn      = module.ecs_cluster.task_role_arn

  target_group_arn = module.lb.ollama_target_group_arn
  container_name   = "ollama-metrics"
  container_port   = 8080

  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id
  service_discovery_name         = "ollama"

  container_definitions = jsonencode([
    {
      name      = "ollama"
      image     = "${module.ecr.ollama_repository_url}:latest"
      essential = true
      portMappings = [{
        containerPort = 11434
        hostPort      = 11434
        protocol      = "tcp"
      }]
      environment = [
        { name = "OLLAMA_HOST", value = "0.0.0.0" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = module.ecs_cluster.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ollama"
        }
      }
    },
    {
      name      = "ollama-metrics"
      image     = "ghcr.io/norskhelsenett/ollama-metrics:latest"
      essential = true
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }]
      environment = [
        { name = "OLLAMA_HOST", value = "http://127.0.0.1:11434" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = module.ecs_cluster.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ollama-metrics"
        }
      }
    },
    local.adot_container
  ])
}

module "ecs_openwebui" {
  source             = "./modules/ecs"
  family             = "openwebui"
  cluster_id         = module.ecs_cluster.cluster_id
  cpu                = var.openwebui_cpu
  memory             = var.openwebui_memory
  desired_count      = var.openwebui_desired_count
  subnet_ids         = [module.network.private_subnet_1_az_id, module.network.private_subnet_2_az_id]
  security_group_ids = [module.security.ecs_sg_id]
  execution_role_arn = module.ecs_cluster.execution_role_arn
  task_role_arn      = module.ecs_cluster.task_role_arn

  target_group_arn = module.lb.openwebui_target_group_arn
  container_name   = "openwebui"
  container_port   = 8080

  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id
  service_discovery_name         = "openwebui"

  container_definitions = jsonencode([
    {
      name      = "openwebui"
      image     = "${module.ecr.openwebui_repository_url}:latest"
      essential = true
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }]
      environment = [
        { name = "OLLAMA_BASE_URL", value = module.lb.ollama_base_url },
        { name = "OLLAMA_BASE_URLS", value = module.lb.ollama_base_url },
        { name = "DATABASE_URL", value = module.db.openwebui_database_url },
        { name = "WEBUI_SECRET_KEY", value = var.webui_secret_key }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = module.ecs_cluster.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "openwebui"
        }
      }
    },
    local.adot_container,
    {
      name      = "openwebui-metrics"
      image     = "nicholascecere/exporter-openwebui:latest"
      essential = false
      portMappings = [{
        containerPort = 9090
        hostPort      = 9090
        protocol      = "tcp"
      }]
      environment = [
        { name = "OPENWEBUI_DB_HOST", value = regex("^postgresql://([^:]+):([^@]+)@([^:]+):(\\d+)/(.+)$", module.db.openwebui_database_url)[2] },
        { name = "OPENWEBUI_DB_PASSWORD", value = regex("^postgresql://([^:]+):([^@]+)@([^:]+):(\\d+)/(.+)$", module.db.openwebui_database_url)[1] },
        { name = "OPENWEBUI_DB_USER", value = regex("^postgresql://([^:]+):([^@]+)@([^:]+):(\\d+)/(.+)$", module.db.openwebui_database_url)[0] },
        { name = "OPENWEBUI_DB_PORT", value = regex("^postgresql://([^:]+):([^@]+)@([^:]+):(\\d+)/(.+)$", module.db.openwebui_database_url)[3] },
        { name = "OPENWEBUI_DB_NAME", value = regex("^postgresql://([^:]+):([^@]+)@([^:]+):(\\d+)/(.+)$", module.db.openwebui_database_url)[4] }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = module.ecs_cluster.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "openwebui-metrics"
        }
      }
    }
  ])
}

module "ecs_prometheus" {
  source             = "./modules/ecs"
  depends_on         = [module.storage]
  family             = "prometheus"
  cluster_id         = module.ecs_cluster.cluster_id
  cpu                = var.prometheus_cpu
  memory             = var.prometheus_memory
  desired_count      = var.prometheus_desired_count
  subnet_ids         = [module.network.private_subnet_1_az_id, module.network.private_subnet_2_az_id]
  security_group_ids = [module.security.ecs_sg_id]
  execution_role_arn = module.ecs_cluster.execution_role_arn
  task_role_arn      = module.ecs_cluster.task_role_arn

  target_group_arn = module.lb.prometheus_target_group_arn
  container_name   = "prometheus"
  container_port   = 9090

  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id
  service_discovery_name         = "prometheus"

  volumes = [
    {
      name = "prometheus-storage"
      efs_volume_configuration = {
        file_system_id     = module.storage.efs_id
        transit_encryption = "ENABLED"
        authorization_config = {
          access_point_id = module.storage.efs_access_point_id
          iam             = "ENABLED"
        }
      }
    }
  ]

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = "${module.ecr.prometheus_repository_url}:latest"
      essential = true
      user      = "0:0"
      command = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--storage.tsdb.path=/prometheus",
        "--web.console.libraries=/usr/share/prometheus/console_libraries",
        "--web.console.templates=/usr/share/prometheus/consoles",
        "--web.route-prefix=/prometheus",
        "--web.external-url=/prometheus",
        "--web.enable-lifecycle"
      ]
      portMappings = [{
        containerPort = 9090
        hostPort      = 9090
        protocol      = "tcp"
      }]
      mountPoints = [{
        sourceVolume  = "prometheus-storage"
        containerPath = "/prometheus"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = module.ecs_cluster.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "prometheus"
        }
      }
    },
    local.adot_container
  ])
}

module "ecs_grafana" {
  source             = "./modules/ecs"
  family             = "grafana"
  cluster_id         = module.ecs_cluster.cluster_id
  cpu                = var.grafana_cpu
  memory             = var.grafana_memory
  desired_count      = var.grafana_desired_count
  subnet_ids         = [module.network.private_subnet_1_az_id, module.network.private_subnet_2_az_id]
  security_group_ids = [module.security.ecs_sg_id]
  execution_role_arn = module.ecs_cluster.execution_role_arn
  task_role_arn      = module.ecs_cluster.task_role_arn

  target_group_arn = module.lb.grafana_target_group_arn
  container_name   = "grafana"
  container_port   = 3000

  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id
  service_discovery_name         = "grafana"

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "${module.ecr.grafana_repository_url}:latest"
      essential = true
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }]
      environment = [
        { name = "GF_SERVER_ROOT_URL", value = "%(protocol)s://%(domain)s/grafana/" },
        { name = "GF_SERVER_SERVE_FROM_SUB_PATH", value = "true" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = module.ecs_cluster.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "grafana"
        }
      }
    },
    local.adot_container
  ])
}

module "sns" {
  source   = "./modules/sns"
  protocol = var.protocol
  endpoint = var.endpoint
}

module "monitoring" {
  source     = "./modules/monitoring"
  depends_on = [module.ecs_grafana, module.ecs_prometheus]

  aws_region                     = var.aws_region
  sns_topic_arn                  = module.sns.sns_topic_arn
  alb_dns_name                   = module.lb.alb_dns_name
  alb_arn_suffix                 = module.lb.alb_arn_suffix
  target_group_arn_suffix        = module.lb.openwebui_target_group_arn_suffix
  ollama_lb_arn_suffix           = module.lb.ollama_lb_arn_suffix
  ollama_target_group_arn_suffix = module.lb.ollama_target_group_arn_suffix
  ecs_cluster_name               = module.ecs_cluster.cluster_name
  ollama_service_name            = module.ecs_ollama.service_name
  openwebui_service_name         = module.ecs_openwebui.service_name
  rds_identifier                 = module.db.rds_identifier
  endpoint                       = var.endpoint
  slack_webhook_url              = var.slack_webhook_url
  pagerduty_integration_key      = var.pagerduty_integration_key
}
