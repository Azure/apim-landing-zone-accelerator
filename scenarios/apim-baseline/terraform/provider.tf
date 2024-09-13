terraform {

  backend "azurerm" {
    # ----------------------
    # Will be passing in these arguments via CLI as the state file \
    #  is now being overwritten via local testing environments
    # > https://developer.hashicorp.com/terraform/language/settings/backends/configuration#command-line-key-value-pairs
    # ----------------------
    # e.g: terraform init \
    #        -backend-config="resource_group_name=rg-tfstate-auseast"     \
    #        -backend-config="storage_account_name=tfstateauseaststorage" \
    #        -backend-config="container_name=apimlza"       \
    #        -backend-config="key=terraform-apimlza-dev-v2.tfstate"
    # ----------------------
    # resource_group_name = "rg-tfstate-auseast"
    # storage_account_name = "tfstateauseaststorage"
    # container_name       = "apimlza"
    # key                  = "terraform-apimlza-dev-v6.tfstate"
  }
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

  # subscription_id = var.subscription_id
  # client_id       = var.client_id
  # client_secret   = var.client_secret
  # tenant_id       = var.tenant_id
}

provider "azapi" {
  # Configuration options
}
