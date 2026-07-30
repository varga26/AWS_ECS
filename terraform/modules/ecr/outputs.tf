output "ollama_repository_url" {
  value = aws_ecr_repository.ollama.repository_url
}
output "openwebui_repository_url" {
  value = aws_ecr_repository.openwebui.repository_url
}
output "prometheus_repository_url" {
  value = aws_ecr_repository.prometheus.repository_url
}
output "grafana_repository_url" {
  value = aws_ecr_repository.grafana.repository_url
}

