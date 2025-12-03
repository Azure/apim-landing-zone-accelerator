terraform {

  # for storage backends, see backend.tf.sample
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    azapi = {
      source = "azure/azapi"
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
}

provider "azapi" {
}
