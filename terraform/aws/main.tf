# AWS Root Configuration
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.0" }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
      Cloud       = "AWS"
    }
  }
}

variable "project"     { type = string; default = "multicloud-demo" }
variable "environment" { type = string; default = "dev" }
variable "region"      { type = string; default = "us-east-1" }

module "vpc" {
  source  = "./modules/vpc"
  project = var.project
  tags    = { Environment = var.environment }
}

module "s3" {
  source      = "./modules/s3"
  project     = var.project
  environment = var.environment
}

module "iam" {
  source        = "./modules/iam"
  project       = var.project
  environment   = var.environment
  s3_bucket_arn = module.s3.bucket_arn
}

output "aws_vpc_id"     { value = module.vpc.vpc_id }
output "aws_bucket_name" { value = module.s3.bucket_name }
output "aws_role_arn"    { value = module.iam.role_arn }
