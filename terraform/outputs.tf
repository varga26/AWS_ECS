output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.network.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value = [
    module.network.public_subnet_1_id,
    module.network.public_subnet_2_id
  ]
}

output "private_compute_subnet_ids" {
  description = "IDs of private compute subnets"
  value = [
    module.network.private_subnet_1_az_id,
    module.network.private_subnet_2_az_id
  ]
}

output "private_db_subnet_ids" {
  description = "IDs of private database subnets"
  value = [
    module.network.private_subnet_1_rds_id,
    module.network.private_subnet_2_rds_id
  ]
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.network.internet_gateway_id
}

output "load_balancer_sg_id" {
  description = "Security group ID for load balancer"
  value       = module.security.lb_sg_id
}

output "ecs_sg_id" {
  description = "Security group ID for ECS tasks"
  value       = module.security.ecs_sg_id
}

output "rds_sg_id" {
  description = "Security group ID for RDS database"
  value       = module.security.rds_sg_id
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.db.rds_endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.db.rds_database_name
}

output "rds_username" {
  description = "RDS database master username"
  value       = module.db.rds_username
  sensitive   = true
}

output "alb_dns_name" {
  description = "DNS name of the load balancer - use this to access OpenWebUI"
  value       = module.lb.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of ECS Cluster"
  value       = module.ecs.cluster_name
}

output "connection_info" {
  description = "Connection information for the deployed resources"
  value = {
    openwebui_url       = "http://${module.lb.alb_dns_name}"
    grafana_url         = "http://${module.lb.alb_dns_name}/grafana"
    prometheus_url      = "http://${module.lb.alb_dns_name}/prometheus"
    rds_connection      = module.db.rds_endpoint
  }
}

output "deployment_summary" {
  description = "Quick summary of deployed infrastructure"
  value = {
    environment         = "production"
    vpc_id              = module.network.vpc_id
    alb_dns             = module.lb.alb_dns_name
    rds_endpoint        = module.db.rds_endpoint
  }
  sensitive = true
}
