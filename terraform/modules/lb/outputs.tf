output "alb_dns_name" { value = aws_lb.lb.dns_name }
output "alb_arn" { value = aws_lb.lb.arn }
output "alb_arn_suffix" { value = aws_lb.lb.arn_suffix }

output "openwebui_target_group_arn" { value = aws_lb_target_group.openwebui_tg.arn }
output "openwebui_target_group_arn_suffix" { value = aws_lb_target_group.openwebui_tg.arn_suffix }

output "grafana_target_group_arn" { value = aws_lb_target_group.grafana_tg.arn }
output "prometheus_target_group_arn" { value = aws_lb_target_group.prometheus_tg.arn }

output "ollama_target_group_arn" { value = aws_lb_target_group.ollama_tg.arn }
output "ollama_target_group_arn_suffix" { value = aws_lb_target_group.ollama_tg.arn_suffix }
output "ollama_lb_arn_suffix" { value = aws_lb.ollama_internal.arn_suffix }
output "ollama_base_url" { value = "http://${aws_lb.ollama_internal.dns_name}:11434" }
