variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "ecs_sg_id" { type = string }
variable "openwebui_tg_arn" { type = string }
variable "grafana_tg_arn" { type = string }
variable "prometheus_tg_arn" { type = string }
variable "ollama_tg_arn" { type = string }
variable "efs_id" { type = string }
variable "efs_ap_id" { type = string }
variable "database_url" { type = string }
variable "webui_secret_key" { type = string }
variable "aws_region" { type = string }
variable "ollama_image" { type = string }
variable "openwebui_image" { type = string }
variable "prometheus_image" { type = string }
variable "grafana_image" { type = string }
variable "ecs_metrics_image" { type = string }
variable "ollama_base_url" { type = string }

variable "ollama_cpu" { type = string }
variable "ollama_memory" { type = string }
variable "ollama_desired_count" { type = number }

variable "openwebui_cpu" { type = string }
variable "openwebui_memory" { type = string }
variable "openwebui_desired_count" { type = number }

variable "prometheus_cpu" { type = string }
variable "prometheus_memory" { type = string }
variable "prometheus_desired_count" { type = number }

variable "grafana_cpu" { type = string }
variable "grafana_memory" { type = string }
variable "grafana_desired_count" { type = number }
