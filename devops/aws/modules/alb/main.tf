locals {
  name_suffix = var.environment
  env_label   = var.environment == "prod" ? "production" : var.environment
}

resource "aws_security_group" "alb" {
  name        = "tsg-alb-${local.name_suffix}"
  description = "ALB ${upper(local.name_suffix)} - HTTP from internet, outbound to VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tsg-alb-${local.name_suffix}"
    Env  = local.env_label
  }
}

resource "aws_lb" "prod" {
  name               = "alb-${local.name_suffix}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  # TODO(ops#19): enable access_logs once the S3 logs bucket exists

  tags = {
    Name = "alb-${local.name_suffix}"
    Env  = local.env_label
  }
}

resource "aws_lb_target_group" "prod" {
  name        = "tg-${local.name_suffix}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "tg-${local.name_suffix}"
    Env  = local.env_label
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prod.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod.arn
  }
}
