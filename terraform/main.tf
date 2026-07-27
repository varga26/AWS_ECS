module "network" {
  source   = "./modules/network"
  vpc_cidr = var.vpc_cidr
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

module "ecs" {
  source = "./modules/ecs"
  vpc_id = module.network.vpc_id
  private_subnet_ids = [module.network.private_subnet_1_az_id, module.network.private_subnet_2_az_id]
  ecs_sg_id = module.security.ecs_sg_id
  
  openwebui_tg_arn  = module.lb.openwebui_target_group_arn
  grafana_tg_arn    = module.lb.grafana_target_group_arn
  prometheus_tg_arn = module.lb.prometheus_target_group_arn
  ollama_tg_arn     = module.lb.ollama_target_group_arn
  ollama_base_url   = module.lb.ollama_base_url
  
  efs_id    = module.storage.efs_id
  efs_ap_id = module.storage.efs_access_point_id
  
  database_url     = module.db.openwebui_database_url
  webui_secret_key = var.webui_secret_key
  aws_region       = var.aws_region
  
  ollama_image     = "${module.ecr.ollama_repository_url}:latest"
  openwebui_image  = "${module.ecr.openwebui_repository_url}:latest"
  prometheus_image = "${module.ecr.prometheus_repository_url}:latest"
  grafana_image    = "${module.ecr.grafana_repository_url}:latest"
}

module "sns" {
  source   = "./modules/sns"
  protocol = var.protocol
  endpoint = var.endpoint
}

module "monitoring" {
  source = "./modules/monitoring"

  aws_region                     = var.aws_region
  sns_topic_arn                  = module.sns.sns_topic_arn
  alb_dns_name                   = module.lb.alb_dns_name
  alb_arn_suffix                 = module.lb.alb_arn_suffix
  target_group_arn_suffix        = module.lb.openwebui_target_group_arn_suffix
  ollama_lb_arn_suffix           = module.lb.ollama_lb_arn_suffix
  ollama_target_group_arn_suffix = module.lb.ollama_target_group_arn_suffix
  ecs_cluster_name               = module.ecs.cluster_name
  ollama_service_name            = module.ecs.ollama_service_name
  openwebui_service_name         = module.ecs.openwebui_service_name
  rds_identifier                 = module.db.rds_identifier
  endpoint                       = var.endpoint
  slack_webhook_url              = var.slack_webhook_url
  pagerduty_integration_key      = var.pagerduty_integration_key
}
