include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../..//devops/aws"
}

inputs = {
  environment        = "staging"
  ecr_repository_arn = get_env("TF_VAR_ecr_repository_arn", "")
  logs_bucket_name   = "devops-project-group1-logs-staging"
  app_postgres_db    = "devops_project_staging"
}
