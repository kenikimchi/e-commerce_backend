terraform {
  required_version = "~> 1.9.8"

  required_providers {
    aws = {
        source = "hashicorp/aws"
				version = ">= 5.75.1"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

#Modules
module "cognito" {
  source = "./modules/user/cognito"

  cognito_username_attributes = var.cognito_username_attributes
  cognito_verified_attributes = var.cognito_verified_attributes
}