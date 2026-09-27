terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25"
    }
  }

  backend "s3" {
    bucket       = "urlshortner-tfstate-dev"
    key          = "terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
    # enabled versioning
  }
}

provider "aws" {
  region = "eu-west-2"
}
