terraform {

  backend "azurerm" {
    # ----------------------
    # Will be passing in these arguments via CLI as the state file \
    #  is now being overwritten via local testing environments
    # > https://developer.hashicorp.com/terraform/language/settings/backends/configuration#command-line-key-value-pairs
    #
    #
    # ----------------------
    # e.g: terraform init \
    #        -backend-config="resource_group_name=rg-tfstate-auseast"     \
    #        -backend-config="storage_account_name=tfstateauseaststorage" \
    #        -backend-config="container_name=apimlza"       \
    #        -backend-config="key=terraform-apimlza-dev-v3.tfstate"
    # ----------------------
    # resource_group_name  = "tfstate"
    # storage_account_name = "tfsaeastus2001"
    # container_name       = "tfstatus"
    # key                  = "scenario3.tfstate"
    # ------
    # for this repository we are setting it up during the execution of the deployment script
    # it takes as an input the .env values
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
