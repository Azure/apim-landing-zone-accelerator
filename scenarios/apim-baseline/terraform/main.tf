locals {
  resourceSuffix              = "${var.workloadName}-${var.environment}-${var.location}-${var.identifier}"
  networkingResourceGroupName = "rg-networking-${local.resourceSuffix}"
  sharedResourceGroupName     = "rg-shared-${local.resourceSuffix}"
  apimResourceGroupName       = "rg-apim-${local.resourceSuffix}"
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
  name     = local.apimResourceGroupName
  location = var.location
}

module "networking" {
  depends_on                   = [azurerm_resource_group.networking]
  source                       = "./modules/networking"
  location                     = var.location
  resourceGroupName            = azurerm_resource_group.networking.name
  resourceSuffix               = local.resourceSuffix
  environment                  = var.environment
  apimAddressPrefix            = var.apimAddressPrefix
  appGatewayAddressPrefix      = var.appGatewayAddressPrefix
  apimCSVNetNameAddressPrefix  = var.apimCSVNetNameAddressPrefix
  privateEndpointAddressPrefix = var.privateEndpointAddressPrefix
  deploymentAddressPrefix      = var.deploymentAddressPrefix
}

module "shared" {
  source              = "./modules/shared"
  location            = var.location
  resourceGroupName   = azurerm_resource_group.shared.name
  resourceSuffix      = local.resourceSuffix
  additionalClientIds = var.additionalClientIds
  keyVaultSku         = var.keyVaultSku
}

module "apim" {
  depends_on         = [module.shared, module.networking]
  source             = "./modules/apim"
  location           = var.location
  resourceGroupName  = azurerm_resource_group.apim.name
  resourceSuffix     = local.resourceSuffix
  environment        = var.environment
  apimSubnetId       = module.networking.apimSubnetId
  instrumentationKey = module.shared.instrumentationKey
  workspaceId        = module.shared.workspaceId
  sharedResourceGroupName = azurerm_resource_group.shared.name
}

module "gateway" {
  depends_on            = [module.networking, module.apim, module.shared]
  source                = "./modules/gateway"
  location              = var.location
  resourceGroupName     = azurerm_resource_group.networking.name
  resourceSuffix        = local.resourceSuffix
  environment           = var.environment
  appGatewayFqdn        = var.appGatewayFqdn
  appGatewayCertType    = var.appGatewayCertType
  certificate_password  = var.certificatePassword
  certificate_path      = var.certificatePath
  subnetId              = module.networking.appGatewaySubnetId
  primaryBackendendFqdn = module.apim.bakendUrl
  keyvaultId            = module.shared.keyVaultId
}

module "dns" {
  depends_on        = [module.apim, module.gateway]
  source            = "./modules/dns"
  location          = var.location
  resourceGroupName = azurerm_resource_group.networking.name
  resourceSuffix    = local.resourceSuffix
  environment       = var.environment
  apimName          = module.apim.apimName
  apimPrivateIp     = module.apim.apimPrivateIp
  apimVnetId        = module.networking.apimVnetId
}
