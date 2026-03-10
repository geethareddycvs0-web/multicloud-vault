# Azure Root Configuration
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
  }
}

provider "azurerm" {
  features {}
}

variable "project"     { type = string; default = "multicloud-demo" }
variable "environment" { type = string; default = "dev" }
variable "location"    { type = string; default = "East US" }

module "resource_group" {
  source      = "./modules/resource-group"
  project     = var.project
  environment = var.environment
  location    = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  project             = var.project
  environment         = var.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
}

module "storage" {
  source              = "./modules/storage"
  project             = var.project
  environment         = var.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
}

output "azure_resource_group"   { value = module.resource_group.resource_group_name }
output "azure_vnet_id"          { value = module.vnet.vnet_id }
output "azure_storage_account"  { value = module.storage.storage_account_name }
