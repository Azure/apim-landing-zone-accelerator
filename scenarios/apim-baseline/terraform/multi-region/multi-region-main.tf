resource "random_string" "suffix" {
  length = 5
  upper = false
  special = false
}

locals {
  resourceSuffix              = "${var.workloadName}-${var.environment}-${var.location}-${var.identifier}"
  networkingResourceGroupName = "rg-networking-${local.resourceSuffix}"
  sharedResourceGroupName     = "rg-shared-${local.resourceSuffix}"
  apimResourceGroupName       = "rg-apim-${local.resourceSuffix}"
  keyVaultName                = substr(lower(replace("kv-${var.workloadName}${random_string.suffix.result}", "-", "")), 0, 23)
  storageAccountName          = substr(lower(replace("sadep${var.workloadName}${random_string.suffix.result}", "-", "")), 0, 21)
  
  # to support multi-region
  resourceSuffix2nd              = "${var.workloadName}-${var.environment}-${var.locationSecond}-${var.identifier}"
  networkingResourceGroupName2nd = "rg-networking-${local.resourceSuffix2nd}"
  sharedResourceGroupName2nd     = "rg-shared-${local.resourceSuffix2nd}"
  apimResourceGroupName2nd       = "rg-apim-${local.resourceSuffix2nd}"  
  keyVaultName2nd                = substr(lower(replace("kv-${var.workloadName}${random_string.suffix.result}-2nd", "-", "")), 0, 23)
  storageAccountName2nd          = substr(lower(replace("sadep2${var.workloadName}${random_string.suffix.result}", "-", "")), 0, 21)
  

  tags = {
    
  }
}


# Global Infra
module "keyvault_dns_zone_multi" {
  depends_on          = [module.networking]
  source              = "../modules/multi_private_dns_zone"
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.networking.name
  virtual_networks_to_link_id = module.networking.apimVnetId
  second_virtual_networks_to_link_id = module.networkingSecond.apimVnetId
  multiRegionEnabled = var.multiRegionEnabled  
}


# Primary Region
resource "azurerm_resource_group" "networking" {
  name     = local.networkingResourceGroupName
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "shared" {
  name     = local.sharedResourceGroupName
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "apim" {
  name     = local.apimResourceGroupName
  location = var.location
  tags     = local.tags
}

module "networking" {
  depends_on                   = [azurerm_resource_group.networking]
  source                       = "../modules/networking"
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
  depends_on           = [module.networking]
  source               = "../modules/multi_shared"
  location             = var.location
  resourceGroupName    = azurerm_resource_group.shared.name
  resourceSuffix       = local.resourceSuffix
  additionalClientIds  = var.additionalClientIds
  keyVaultName         = local.keyVaultName
  keyVaultSku              = var.keyVaultSku
  keyVaultPrivateDnsZoneId = module.keyvault_dns_zone_multi.id
  deploymentSubnetId   = module.networking.deploymentSubnetId
  storage_account_name = local.storageAccountName
}

module "apim" {
  depends_on              = [module.shared, module.networking]
  source                  = "../modules/multi_apim"
  location                = var.location
  resourceGroupName       = azurerm_resource_group.apim.name
  resourceSuffix          = local.resourceSuffix
  environment             = var.environment
  apimSubnetId            = module.networking.apimSubnetId
  instrumentationKey      = module.shared.instrumentationKey
  workspaceId             = module.shared.workspaceId
  sharedResourceGroupName = azurerm_resource_group.shared.name
  keyVaultName            = local.keyVaultName
  
  apimSecondSubnetId      = module.networkingSecond.apimSubnetId
  zoneRedundantEnabled    = var.zoneRedundantEnabled
  locationSecond          = var.locationSecond
}

module "gateway" {
  depends_on              = [module.networking, module.apim, module.shared]
  source                  = "../modules/multi_gateway"
  location                = var.location
  resourceGroupName       = azurerm_resource_group.networking.name
  resourceSuffix          = local.resourceSuffix
  environment             = var.environment
  appGatewayFqdn          = var.appGatewayFqdn
  appGatewayCertType      = var.appGatewayCertType
  certificate_password    = var.certificatePassword
  certificate_path        = var.certificatePath
  subnetId                = module.networking.appGatewaySubnetId
  primaryBackendendFqdn   = module.apim.apim_regional_url_1
  keyvaultId              = module.shared.keyVaultId
  keyVaultName            = module.shared.keyVaultName
  sharedResourceGroupName = azurerm_resource_group.shared.name
  deploymentIdentityName  = module.shared.deploymentIdentityName
  deploymentSubnetId      = module.networking.deploymentSubnetId
  deploymentStorageName   = module.shared.deploymentStorageName
}


module "dns" {
  depends_on        = [module.apim, module.gateway]
  source            = "../modules/dns"
  location          = var.location
  resourceGroupName = azurerm_resource_group.networking.name
  resourceSuffix    = local.resourceSuffix
  environment       = var.environment
  apimName          = module.apim.apimName
  apimPrivateIp     = module.apim.apimPrivateIp
  apimVnetId        = module.networking.apimVnetId
  
}

module "dnsRegional" {
  depends_on              = [module.apim, module.gatewaySecond]

  source                  = "../modules/multi_apim-dns-regional"
  location                = var.location
  resourceGroupName       = azurerm_resource_group.networking.name
  resourceSuffix          = local.resourceSuffix
  environment             = var.environment
  apimRegionalName        = module.apim.apim_regional_name_1
  apimPrivateIp           = module.apim.apim_regional_IP_1
  apimVnetId              = module.networking.apimVnetId
  apimSecondRegionalName  = module.apim.apim_regional_name_2
  apimSecondPrivateIp     = module.apim.apim_regional_IP_2
  apimSecondVnetId        = module.networkingSecond.apimVnetId
}

# Secondary Region
resource "azurerm_resource_group" "networkingSecond" {
  name     = "${local.networkingResourceGroupName2nd}"
  location = var.locationSecond
  tags     = local.tags
}

resource "azurerm_resource_group" "sharedSecond" {
  name     = "${local.sharedResourceGroupName2nd}"
  location = var.locationSecond
  tags     = local.tags
}

resource "azurerm_resource_group" "apimSecond" {
  name     = "${local.apimResourceGroupName2nd}"
  location = var.locationSecond
  tags     = local.tags
}


module "networkingSecond" {
  depends_on                   = [azurerm_resource_group.networkingSecond]
  source                       = "../modules/networking"
  location                     = var.locationSecond
  resourceGroupName            = azurerm_resource_group.networkingSecond.name
  resourceSuffix               = local.resourceSuffix2nd  
  environment                  = var.environment
  apimAddressPrefix            = var.apimSecondAddressPrefix
  appGatewayAddressPrefix      = var.appGatewaySecondAddressPrefix
  apimCSVNetNameAddressPrefix  = var.apimCSVNetNameSecondAddressPrefix
  privateEndpointAddressPrefix = var.privateEndpointSecondAddressPrefix
  deploymentAddressPrefix      = var.deploymentSecondAddressPrefix
}



module "sharedSecond" {
  depends_on           = [module.networkingSecond]
  source               = "../modules/multi_shared"
  location             = var.locationSecond
  resourceGroupName    = azurerm_resource_group.sharedSecond.name
  resourceSuffix       = local.resourceSuffix2nd  
  additionalClientIds  = var.additionalClientIds
  keyVaultName         = "${local.keyVaultName}-2nd"
  keyVaultSku          = var.keyVaultSku
  keyVaultPrivateDnsZoneId = module.keyvault_dns_zone_multi.id
  deploymentSubnetId   = module.networkingSecond.deploymentSubnetId
  storage_account_name = local.storageAccountName2nd
}


module "gatewaySecond" {
  depends_on              = [module.networkingSecond, module.apim, module.sharedSecond]
  source                  = "../modules/multi_gateway"
  location                = var.locationSecond
  resourceGroupName       = azurerm_resource_group.networkingSecond.name
  resourceSuffix          = local.resourceSuffix2nd
  environment             = var.environment
  appGatewayFqdn          = var.appGatewayFqdn
  appGatewayCertType      = var.appGatewayCertType
  certificate_password    = var.certificatePassword
  certificate_path        = var.certificatePath
  subnetId                = module.networkingSecond.appGatewaySubnetId
  
  primaryBackendendFqdn   = module.apim.apim_regional_url_2
  keyvaultId              = module.sharedSecond.keyVaultId
  keyVaultName            = module.sharedSecond.keyVaultName
  sharedResourceGroupName = azurerm_resource_group.sharedSecond.name
  deploymentIdentityName  = module.sharedSecond.deploymentIdentityName
  deploymentSubnetId      = module.networkingSecond.deploymentSubnetId
  deploymentStorageName   = module.sharedSecond.deploymentStorageName
}

module "trafficmanager" {
  depends_on          = [module.apim, module.gateway, module.gatewaySecond]
  source              = "../modules/multi_traffic_manager"
  name                = replace(var.appGatewayFqdn,".","-")
  resourceGroupName   = azurerm_resource_group.networking.name
  environment         = var.environment
  primaryName         = module.gateway.app_gateway_name
  primaryPublicIpId   = module.gateway.gw_pip_id
  secondaryName       = module.gatewaySecond.app_gateway_name
  secondaryPublicIpId = module.gatewaySecond.gw_pip_id
}