provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  az1    = var.az1
  az2    = var.az2
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
