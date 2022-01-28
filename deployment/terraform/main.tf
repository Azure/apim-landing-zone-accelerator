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

resource "azurerm_resource_group" "hub_rg" {
  name     = "hub-rg-002"
  location = "East US"
}

module "networking" {
  source = "./networking"

  workload_name             = "pm-t"
  resource_group_name       = azurerm_resource_group.hub_rg.name
  resource_group_location   = azurerm_resource_group.hub_rg.location
  deployment_environment    = "dev"
}