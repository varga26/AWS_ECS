output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ollama_service_name" {
  value = aws_ecs_service.ollama.name
}

output "openwebui_service_name" {
  value = aws_ecs_service.openwebui.name
}
