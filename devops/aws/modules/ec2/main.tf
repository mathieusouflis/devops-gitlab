# Latest official Debian 12 (Bookworm) AMI
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian official AWS account

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {

  ssm_prefix = "/group1/${var.environment}"
}

# Security Group for EC2 instances
resource "aws_security_group" "ec2_prod" {
  name        = "W2A1-tsg-ec2-${var.environment}"
  description = "${upper(var.environment)} EC2 - HTTP from VPC (ALB), all outbound"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from VPC (ALB will restrict this further)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "W2A1-tsg-ec2-${var.environment}"
    Env  = var.environment
  }
}

# Launch Template
resource "aws_launch_template" "prod" {
  name_prefix   = "W2A1-lt-${var.environment}-"
  image_id      = data.aws_ami.debian.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.ecr_read_instance_profile_name
  }

  vpc_security_group_ids = [aws_security_group.ec2_prod.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    region             = var.aws_region
    ecr_registry       = var.ecr_registry
    ecr_repository_uri = var.ecr_repository_uri
    environment        = var.environment
    ssm_prefix         = local.ssm_prefix
    cloudwatch_app_log_group_name    = var.cloudwatch_app_log_group_name
    cloudwatch_system_log_group_name = var.cloudwatch_system_log_group_name
    init_sql_b64       = base64encode(file("${path.root}/../../devops/docker/postgres/init.sql"))
    nginx_conf_b64     = base64encode(file("${path.root}/../../devops/docker/nginx/nginx.prod.conf"))
    compose_b64        = base64encode(file("${path.root}/../../docker-compose.ecr.yaml"))
  }))

  # Enforce IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "W2A1-ec2-${var.environment}"
      Env  = var.environment
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "W2A1-ec2-${var.environment}-volume"
      Env  = var.environment
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "prod" {
  name                = "W2A1-asg-${var.environment}"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.prod.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "W2A1-ec2-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = var.environment
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
