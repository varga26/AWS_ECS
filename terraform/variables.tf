variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "state_bucket_name" {
  type    = string
  default = "terraform-state-bucket-7779823758347t093"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "mydb"
}

variable "db_engine_version" {
  type    = string
  default = "16"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_parameter_group_name" {
  type    = string
  default = "default.postgres16"
}

variable "webui_secret_key" {
  type        = string
  description = "Secret key for OpenWebUI web interface"
}

variable "db_username" {
  type        = string
  description = "Database master user"
  default     = "postgres"
}

variable "db_password" {
  type        = string
  description = "Database master password"
  sensitive   = true
}

variable "endpoint" {
  type        = string
  description = "Email address for receiving CloudWatch alarms"
}

variable "protocol" {
  type    = string
  default = "email"
}

variable "slack_webhook_url" {
  type        = string
  description = "Slack incoming webhook URL for Grafana alert notifications (leave empty to disable)"
  default     = ""
  sensitive   = true
}

variable "pagerduty_integration_key" {
  type        = string
  description = "PagerDuty Events v2 integration key (leave empty to disable)"
  default     = ""
  sensitive   = true
}

# --- Network Subnet CIDRs ---
variable "private_subnet_1_az_cidr" { default = "10.0.0.0/27" }
variable "private_subnet_2_az_cidr" { default = "10.0.0.32/27" }
variable "private_subnet_1_rds_cidr" { default = "10.0.0.64/27" }
variable "private_subnet_2_rds_cidr" { default = "10.0.0.96/27" }
variable "public_subnet_1_cidr" { default = "10.0.0.128/27" }
variable "public_subnet_2_cidr" { default = "10.0.0.160/27" }

# --- ECS Service Parameters ---
variable "ollama_cpu" { default = "4096" }
variable "ollama_memory" { default = "16384" }
variable "ollama_desired_count" { default = 2 }

variable "openwebui_cpu" { default = "1024" }
variable "openwebui_memory" { default = "2048" }
variable "openwebui_desired_count" { default = 2 }

variable "prometheus_cpu" { default = "1024" }
variable "prometheus_memory" { default = "2048" }
variable "prometheus_desired_count" { default = 1 }

variable "grafana_cpu" { default = "512" }
variable "grafana_memory" { default = "1024" }
variable "grafana_desired_count" { default = 1 }
