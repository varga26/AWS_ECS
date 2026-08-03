variable "vpc_id" {
  description = "VPC ID for Service Discovery namespace"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "llm-ecs-cluster"
}

variable "log_group_name" {
  description = "CloudWatch log group name for ECS tasks"
  type        = string
  default     = "/ecs/llm-app"
}

variable "log_retention_in_days" {
  description = "Retention period for CloudWatch logs in days"
  type        = number
  default     = 14
}

variable "namespace_name" {
  description = "Private DNS namespace for service discovery"
  type        = string
  default     = "ecs.local"
}
