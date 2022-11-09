terraform {

  backend "azurerm" {
    resource_group_name = "rg-terraform"
    storage_account_name = "apimlztfbackend"
    container_name       = "terraform-state"
    key                  = "es-apim-lza.tfstate"
    # resource_group_name = "tfstate"
    # storage_account_name = "tfstate1259034575"
    # container_name       = "tfstate"
    # key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.95.0"
    }
  }
}

# Configure the Microsft Azure provider
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}
