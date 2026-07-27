resource "aws_lb" "lb" {
  name               = "llm-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg_id]
  subnets            = [var.public_subnet_1_id, var.public_subnet_2_id]
}

# --- Target Groups ---
resource "aws_lb_target_group" "openwebui_tg" {
  name        = "openwebui-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/health"
  }
}

resource "aws_lb_target_group" "grafana_tg" {
  name        = "grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/api/health"
  }
}

resource "aws_lb_target_group" "prometheus_tg" {
  name        = "prometheus-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/-/healthy"
  }
}

resource "aws_lb_target_group" "ollama_tg" {
  name        = "ollama-tg"
  port        = 11434
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/"
  }
}

# --- Internal LB for Ollama (so OpenWebUI can connect via DNS) ---
resource "aws_lb" "ollama_internal" {
  name               = "ollama-internal"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.lb_sg_id]
  subnets            = [var.private_subnet_1_id, var.private_subnet_2_id]
}

resource "aws_lb_listener" "ollama_listener" {
  load_balancer_arn = aws_lb.ollama_internal.arn
  port              = 11434
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ollama_tg.arn
  }
}

# --- Public ALB Listeners ---
resource "aws_lb_listener" "http_80" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.openwebui_tg.arn
  }
}

# Path-based routing rules on port 80
resource "aws_lb_listener_rule" "grafana_rule" {
  listener_arn = aws_lb_listener.http_80.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }

  condition {
    path_pattern {
      values = ["/grafana*"]
    }
  }
}

resource "aws_lb_listener_rule" "prometheus_rule" {
  listener_arn = aws_lb_listener.http_80.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus_tg.arn
  }

  condition {
    path_pattern {
      values = ["/prometheus*"]
    }
  }
}
