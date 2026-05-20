include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../..//devops/aws"
}

inputs = {
  environment      = "staging"
  logs_bucket_name = "devops-project-group1-logs-staging"
  app_postgres_db  = "devops_project_staging"
}
