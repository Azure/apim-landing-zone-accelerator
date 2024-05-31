locals {
  resourceSuffix              = "${var.workloadName}-${var.environment}-${var.location}-${random_string.random_identifier.result}"
  networkingResourceGroupName = "rg-networking-${local.resourceSuffix}"
  sharedResourceGroupName     = "rg-shared-${local.resourceSuffix}"
  apimResourceGroupName       = "rg-apim-${local.resourceSuffix}"
}

resource "random_string" "random_identifier" {
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_resource_group" "networking" {
  name     = local.networkingResourceGroupName
  location = var.location
}

resource "azurerm_resource_group" "shared" {
  name     = local.sharedResourceGroupName
  location = var.location
}

resource "azurerm_resource_group" "apim" {
  name     = local.sharedResourceGroupName
  location = var.location
}

module "networking" {
  source                       = "./modules/networking"
  location                     = var.location
  resourceGroupName            = local.networkingResourceGroupName
  resourceSuffix               = local.resourceSuffix
  environment                  = var.environment
  apimAddressPrefix            = var.apimAddressPrefix
  appGatewayAddressPrefix      = var.appGatewayAddressPrefix
  apimCSVNetNameAddressPrefix  = var.apimCSVNetNameAddressPrefix
  privateEndpointAddressPrefix = var.privateEndpointAddressPrefix
  deploymentAddressPrefix      = var.deploymentAddressPrefix
}