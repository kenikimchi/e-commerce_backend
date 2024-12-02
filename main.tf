terraform {
  required_version = "~> 1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
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

  cognito_username_attributes  = var.cognito_username_attributes
  cognito_verified_attributes  = var.cognito_verified_attributes
  guest_cart_table_arn         = module.dynamodb.guest_cart_table_arn
  cognito_client_name          = var.cognito_client_name
  cognito_client_callback_urls = var.cognito_client_callback_urls
  user_pool_domain_domain      = var.user_pool_domain_domain
}

module "dynamodb" {
  source                = "./modules/order/dynamodb"
  guest_cart_range_key  = var.guest_cart_range_key
  guest_cart_hash_key   = var.guest_cart_hash_key
  guest_cart_table_name = var.guest_cart_table_name
}

module "lambda" {
  source                          = "./modules/order/lambda"
  lambda_cart_service_bucket_name = var.lambda_cart_service_bucket_name
  dynamodb_guest_cart_arn         = module.dynamodb.guest_cart_table_arn
  get-cart_s3_key                 = var.get-cart_s3_key
  github_svc                      = var.github_svc
}

module "apigateway" {
  source                   = "./modules/order/apigateway"
  get_cart_integration_uri = module.lambda.get-cart_invoke_arn
}

module "vpc" {
  source               = "./modules/hosting/vpc"
  main_cidr_block      = var.main_cidr_block
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  project_name         = var.project_name
}

# module "nat" {
#   source               = "./modules/hosting/nat"
#   private_subnet_ids   = module.vpc.private_subnet_ids
#   vpc_id               = module.vpc.vpc_id
#   private_subnet_cidrs = var.private_subnet_cidrs
#   public_subnet_ids    = module.vpc.public_subnet_ids
# }