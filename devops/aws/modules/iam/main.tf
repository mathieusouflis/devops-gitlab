data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  ssm_parameter_prefix = "/group1/${var.environment}"
}

# Shared trust policy

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# EC2-ECR-ReadRole

resource "aws_iam_role" "ecr_read" {
  name               = "W2A1-EC2-ECR-ReadRole-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Name = "W2A1-EC2-ECR-ReadRole-${var.environment}"
    Env  = var.environment
  }

  lifecycle {
    ignore_changes = all
  }
}

data "aws_iam_policy_document" "ecr_read" {
  # GetAuthorizationToken must target "*" — it is an account-level API call
  # that does not accept a resource ARN. This is an AWS constraint, not a
  # policy choice. It only returns a short-lived Docker login token and does
  # not grant access to any repository content.
  statement {
    sid       = "ECRAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPull"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = [var.ecr_repository_arn]
  }

  statement {
    sid    = "SSMGetParams"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = ["arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_parameter_prefix}/*"]
  }
}

# SSM Session Manager — allows `aws ssm start-session` without opening port 22
resource "aws_iam_role_policy_attachment" "ecr_read_ssm" {
  role       = aws_iam_role.ecr_read.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "ecr_read" {
  name   = "W2A1-EC2-ECR-ReadPolicy-${var.environment}"
  policy = data.aws_iam_policy_document.ecr_read.json

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ecr_read.name
  policy_arn = aws_iam_policy.ecr_read.arn
}

resource "aws_iam_instance_profile" "ecr_read" {
  name = "W2A1-EC2-ECR-ReadRole-${var.environment}-profile"
  role = aws_iam_role.ecr_read.name

  lifecycle {
    ignore_changes = all
  }
}

# EC2-S3-WriteRole

resource "aws_iam_role" "s3_write" {
  name               = "W2A1-EC2-S3-WriteRole-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Name = "W2A1-EC2-S3-WriteRole-${var.environment}"
    Env  = var.environment
  }

  lifecycle {
    ignore_changes = all
  }
}

data "aws_iam_policy_document" "s3_write" {
  statement {
    sid     = "S3WriteLogs"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    # Scoped to the logs bucket only — no wildcard on resources
    resources = ["arn:aws:s3:::${var.logs_bucket_name}/*"]
  }
}

resource "aws_iam_policy" "s3_write" {
  name   = "W2A1-EC2-S3-WritePolicy-${var.environment}"
  policy = data.aws_iam_policy_document.s3_write.json

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_iam_role_policy_attachment" "s3_write" {
  role       = aws_iam_role.s3_write.name
  policy_arn = aws_iam_policy.s3_write.arn
}

resource "aws_iam_instance_profile" "s3_write" {
  name = "W2A1-EC2-S3-WriteRole-${var.environment}-profile"
  role = aws_iam_role.s3_write.name

  lifecycle {
    ignore_changes = all
  }
}
