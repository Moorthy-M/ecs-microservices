terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "s3-moorthy-terraform-state"
    key          = "ecs-microservices/services/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "ap-south-1"
}