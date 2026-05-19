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
  name               = "EC2-ECR-ReadRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Name = "EC2-ECR-ReadRole"
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
}

resource "aws_iam_policy" "ecr_read" {
  name   = "EC2-ECR-ReadPolicy"
  policy = data.aws_iam_policy_document.ecr_read.json
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ecr_read.name
  policy_arn = aws_iam_policy.ecr_read.arn
}

resource "aws_iam_instance_profile" "ecr_read" {
  name = "EC2-ECR-ReadRole-profile"
  role = aws_iam_role.ecr_read.name
}

# EC2-S3-WriteRole

resource "aws_iam_role" "s3_write" {
  name               = "EC2-S3-WriteRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Name = "EC2-S3-WriteRole"
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
  name   = "EC2-S3-WritePolicy"
  policy = data.aws_iam_policy_document.s3_write.json
}

resource "aws_iam_role_policy_attachment" "s3_write" {
  role       = aws_iam_role.s3_write.name
  policy_arn = aws_iam_policy.s3_write.arn
}

resource "aws_iam_instance_profile" "s3_write" {
  name = "EC2-S3-WriteRole-profile"
  role = aws_iam_role.s3_write.name
}
