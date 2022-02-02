locals {
  resource_suffix = "001"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.93.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "hub_rg" {
  name     = "hub-rg-002"
  location = "East US"
}

module "shared" {
  source = "./shared"

  tenant_id                 = data.azurerm_client_config.current.tenant_id
  resource_group_name       = azurerm_resource_group.hub_rg.name
  resource_group_location   = azurerm_resource_group.hub_rg.location
  workload_name             = "pm-t"
  resource_suffix           = local.resource_suffix
  deployment_environment    = "dev"
}

module "networking" {
  source = "./networking"

  resource_group_name       = azurerm_resource_group.hub_rg.name
  resource_group_location   = azurerm_resource_group.hub_rg.location
  workload_name             = "pm-t"
  deployment_environment    = "dev"
}