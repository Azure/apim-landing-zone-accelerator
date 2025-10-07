terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.0"
    }
  }
}

# Configure the Microsft Azure provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  use_oidc = true
  storage_use_azuread = true
  subscription_id = var.subscription_id
  # client_id       = var.client_id
  # client_secret   = var.client_secret
  # tenant_id       = var.tenant_id
}

provider "azapi" {
  # Configuration options
}
