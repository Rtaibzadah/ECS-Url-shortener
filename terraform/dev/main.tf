locals {
  common_tags = {
    Project     = "ecs-url-shortener"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source           = "../modules/vpc"
  common_tags      = local.common_tags
  vpc_cidr         = "10.0.0.0/16"
  vpc_endpoints_sg = module.sgs.vpc_endpoints_sg
  region           = "eu-west-2"
}

module "sgs" {
  source      = "../modules/sgs"
  common_tags = local.common_tags
  vpc_id      = module.vpc.vpc_id
  # vpc_cidr    = "10.0.0.0/16"
}
