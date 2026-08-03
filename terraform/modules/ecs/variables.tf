variable "family" {
  description = "Task definition family and base name for the service"
  type        = string
}

variable "service_name" {
  description = "Custom service name (defaults to {family}-service)"
  type        = string
  default     = null
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task definition (e.g. 512, 1024, 2048)"
  type        = any
  default     = "1024"
}

variable "memory" {
  description = "Memory for the task definition in MiB (e.g. 1024, 2048, 4096)"
  type        = any
  default     = "2048"
}

variable "desired_count" {
  description = "Desired number of task instances"
  type        = number
  default     = 1
}

variable "launch_type" {
  description = "Launch type for the service"
  type        = string
  default     = "FARGATE"
}

variable "force_new_deployment" {
  description = "Enable force new deployment on service updates"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "Subnet IDs for the task awsvpc network configuration"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the task awsvpc network configuration"
  type        = list(string)
}

variable "execution_role_arn" {
  description = "IAM role ARN for ECS task execution"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN for ECS task"
  type        = string
}

variable "container_definitions" {
  description = "JSON-encoded container definitions string"
  type        = string
}

variable "volumes" {
  description = "Optional volume definitions for the task definition"
  type        = any
  default     = []
}

variable "target_group_arn" {
  description = "Target group ARN for ALB integration (optional)"
  type        = string
  default     = null
}

variable "container_name" {
  description = "Container name to attach to target group (defaults to var.family)"
  type        = string
  default     = null
}

variable "container_port" {
  description = "Container port to attach to target group"
  type        = number
  default     = null
}

variable "enable_service_discovery" {
  description = "Enable AWS Cloud Map Service Discovery registration"
  type        = bool
  default     = true
}

variable "service_discovery_namespace_id" {
  description = "Service discovery private DNS namespace ID (optional)"
  type        = string
  default     = null
}

variable "service_discovery_name" {
  description = "Service discovery record name (defaults to var.family)"
  type        = string
  default     = null
}

variable "service_discovery_dns_ttl" {
  description = "TTL for DNS records in service discovery"
  type        = number
  default     = 10
}