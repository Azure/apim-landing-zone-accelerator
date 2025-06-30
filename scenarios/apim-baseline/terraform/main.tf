# locals {
#   resourceSuffix              = "${var.workloadName}-${var.environment}-${var.location}-${var.identifier}"
#   networkingResourceGroupName = "rg-networking-${local.resourceSuffix}"
#   sharedResourceGroupName     = "rg-shared-${local.resourceSuffix}"
#   apimResourceGroupName       = "rg-apim-${local.resourceSuffix}"
#   keyVaultName                = "kv-${var.workloadName}-${var.environment}-${var.identifier}"
#   resourceSuffixSecond        = "${var.workloadName}-${var.environment}-${var.locationSecond}-${var.identifier}"

#   tags = {
#   }
# }

# This module deploys an Azure API Management (APIM) service in a single region.
module "apim_baseline_single_region" {

    count = var.multiRegionEnabled ? 0 : 1    

    source = "./single-region"

    location                    = var.location
    workloadName                = var.workloadName
    appGatewayFqdn              = var.appGatewayFqdn
    appGatewayCertType          = var.appGatewayCertType
    environment                 = var.environment
    apimCSVNetNameAddressPrefix = var.apimCSVNetNameAddressPrefix
    appGatewayAddressPrefix     = var.appGatewayAddressPrefix
    apimAddressPrefix           = var.apimAddressPrefix
    privateEndpointAddressPrefix = var.privateEndpointAddressPrefix
    deploymentAddressPrefix     = var.deploymentAddressPrefix
    additionalClientIds          = var.additionalClientIds
#    keyVaultName                = local.keyVaultName
#    keyVaultSku                 = var.keyVaultSku
#    resourceSuffix              = local.resourceSuffix
#    tags                        = local.tags  
    certificatePassword        = var.certificatePassword
    certificatePath            = var.certificatePath
    identifier                 = var.identifier    

}


module "apim_baseline_multi_region" {

    count = var.multiRegionEnabled ? 1 : 0  

    source = "./multi-region"

    location                    = var.location
    workloadName                = var.workloadName
    appGatewayFqdn              = var.appGatewayFqdn
    appGatewayCertType          = var.appGatewayCertType
    environment                 = var.environment
    apimCSVNetNameAddressPrefix = var.apimCSVNetNameAddressPrefix
    appGatewayAddressPrefix     = var.appGatewayAddressPrefix
    apimAddressPrefix           = var.apimAddressPrefix
    privateEndpointAddressPrefix = var.privateEndpointAddressPrefix
    deploymentAddressPrefix     = var.deploymentAddressPrefix
    additionalClientIds          = var.additionalClientIds
#    keyVaultName                = local.keyVaultName
#    keyVaultSku                 = var.keyVaultSku
#    resourceSuffix              = local.resourceSuffix
#    tags                        = local.tags  
    certificatePassword        = var.certificatePassword
    certificatePath            = var.certificatePath
    identifier                 = var.identifier
    apimCSVNetNameSecondAddressPrefix = var.apimCSVNetNameSecondAddressPrefix
    appGatewaySecondAddressPrefix = var.appGatewaySecondAddressPrefix
    apimSecondAddressPrefix = var.apimSecondAddressPrefix
    privateEndpointSecondAddressPrefix = var.privateEndpointSecondAddressPrefix
    deploymentSecondAddressPrefix = var.deploymentSecondAddressPrefix
    locationSecond = var.locationSecond
    zoneRedundantEnabled = var.zoneRedundantEnabled
        

}

