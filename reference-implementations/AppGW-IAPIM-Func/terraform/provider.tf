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
