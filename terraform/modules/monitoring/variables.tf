variable "aws_region" { type = string }
variable "sns_topic_arn" { type = string }
variable "alb_dns_name" { type = string }
variable "alb_arn_suffix" { type = string }
variable "target_group_arn_suffix" { type = string }
variable "ollama_lb_arn_suffix" { type = string }
variable "ollama_target_group_arn_suffix" { type = string }
variable "ecs_cluster_name" { type = string }
variable "ollama_service_name" { type = string }
variable "openwebui_service_name" { type = string }
variable "rds_identifier" { type = string }
variable "endpoint" { type = string }
variable "slack_webhook_url" {
  type      = string
  default   = ""
  sensitive = true
}
variable "pagerduty_integration_key" {
  type      = string
  default   = ""
  sensitive = true
}
