terraform {
  
  backend "azurerm" {
    storage_account_name = "apimlztfbackend "
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
    
  }
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.95.0"
    }
  }
}

# Configure the Microosft Azure provider 
provider "azurerm" {
  features {}
  
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}
