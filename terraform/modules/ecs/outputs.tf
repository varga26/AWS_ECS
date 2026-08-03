output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.this.id
}

output "task_definition_arn" {
  description = "ARN of the Task Definition"
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_family" {
  description = "Family of the Task Definition"
  value       = aws_ecs_task_definition.this.family
}

output "service_discovery_service_arn" {
  description = "ARN of the Service Discovery Service"
  value       = length(aws_service_discovery_service.this) > 0 ? aws_service_discovery_service.this[0].arn : null
}
