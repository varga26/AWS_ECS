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
