include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../..//devops/aws"
}

inputs = {
  environment        = "production"
  ecr_repository_arn = get_env("AWS_ECR_REPOSITORY_ARN", "")
}
