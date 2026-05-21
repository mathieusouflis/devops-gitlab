provider "aws" {
  region = var.aws_region
}

locals {
  ecr_account_id     = split(":", var.ecr_repository_arn)[4]
  ecr_registry       = "${local.ecr_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  ecr_repository_uri = "${local.ecr_registry}/${split("repository/", var.ecr_repository_arn)[1]}"
}

module "iam" {
  source              = "./modules/iam"
  environment         = var.environment
  ecr_repository_arn  = var.ecr_repository_arn
  logs_bucket_name    = var.logs_bucket_name
}

module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
  az1         = var.az1
  az2         = var.az2
  public_subnets_config = {
    "subnet_public_1" = {
      name   = "subnet_public_1"
      az     = var.az1
      cidr   = "10.0.1.0/24"
      public = true
    },
    "subnet_public_2" = {
      name   = "subnet_public_2"
      cidr   = "10.0.2.0/24"
      az     = var.az2
      public = true
    }
  }
  private_subnets_config = {
    "subnet_private_1" = {
      name   = "subnet_private_1"
      cidr   = "10.0.3.0/24"
      az     = var.az1
      public = false
    },
    "subnet_private_2" = {
      name   = "subnet_private_2"
      cidr   = "10.0.4.0/24"
      az     = var.az2
      public = false
    }
  }
  vpc_cidr = var.vpc_cidr
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
  environment       = var.environment
}

module "ssm" {
  source = "./modules/ssm"

  environment        = var.environment
  postgres_user      = var.app_postgres_user
  postgres_password  = var.app_postgres_password
  postgres_db        = var.app_postgres_db
  backend_port       = var.app_backend_port
  alb_dns_name       = module.alb.dns_name
  vite_frontend_port = var.app_vite_frontend_port
  http_port          = var.app_http_port
}

module "ec2" {
  source                         = "./modules/ec2"
  environment                    = var.environment
  aws_region                     = var.aws_region
  vpc_id                         = module.vpc.vpc_id
  private_subnet_ids             = module.vpc.private_subnets
  vpc_cidr                       = var.vpc_cidr
  ecr_registry                   = local.ecr_registry
  ecr_repository_uri             = local.ecr_repository_uri
  ecr_read_instance_profile_name = module.iam.ecr_read_instance_profile_name
  target_group_arn               = module.alb.target_group_arn
}
