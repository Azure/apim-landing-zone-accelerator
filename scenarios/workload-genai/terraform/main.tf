locals {
  resourceSuffix               = "${var.workloadName}-${var.environment}-${var.location}-${var.identifier}"
  networkingResourceGroupName  = "rg-networking-${local.resourceSuffix}"
  apimResourceGroupName        = "rg-apim-${local.resourceSuffix}"
  apimName                     = "apim-${local.resourceSuffix}"
  openaiResourceGroupName      = "rg-openai-${local.resourceSuffix}"
  apim_cs_vnet_name            = "vnet-apim-cs-${local.resourceSuffix}"
  deploy_subnet_name           = "snet-deploy-${local.resourceSuffix}"
  private_endpoint_subnet_name = "snet-prep-${local.resourceSuffix}"
  eventHubNamespaceName        = "eh-ns-${local.resourceSuffix}"
  apimIdentityName             = "identity-${local.apimName}"
}

data "azurerm_client_config" "current" {
}

data "azurerm_api_management" "apim" {
  name                = local.apimName
  resource_group_name = local.apimResourceGroupName
}

data "azurerm_resource_group" "networking" {
  name = local.networkingResourceGroupName
}

data "azurerm_resource_group" "apim" {
  name = local.apimResourceGroupName
}

data "azurerm_virtual_network" "apim_cs_vnet" {
  name                = local.apim_cs_vnet_name
  resource_group_name = local.networkingResourceGroupName
}

data "azurerm_subnet" "private_endpoint_subnet" {
  name                 = local.private_endpoint_subnet_name
  resource_group_name  = local.networkingResourceGroupName
  virtual_network_name = local.apim_cs_vnet_name
}

data "azurerm_subnet" "deploy_subnet" {
  name                 = local.deploy_subnet_name
  resource_group_name  = local.networkingResourceGroupName
  virtual_network_name = local.apim_cs_vnet_name
}

data "azurerm_user_assigned_identity" "apimIdentity" {
  name                = local.apimIdentityName
  resource_group_name = local.apimResourceGroupName
}

resource "azurerm_resource_group" "rg" {
  name     = local.openaiResourceGroupName
  location = var.location
}


module "openai_private_dns_zone" {
  source                      = "./modules/private_dns_zone"
  name                        = "privatelink.openai.azure.com"
  resource_group_name         = azurerm_resource_group.rg.name
  virtual_networks_to_link_id = data.azurerm_virtual_network.apim_cs_vnet.id
}

module "openai_simulatedPTUDeployment_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "pep-${module.simulatedPTUDeployment.name}"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = data.azurerm_subnet.private_endpoint_subnet.id
  private_connection_resource_id = module.simulatedPTUDeployment.id
  is_manual_connection           = false
  subresource_name               = "account"
  private_dns_zone_group_name    = "OpenAiPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.openai_private_dns_zone.id]
}

module "openai_simulatedPaygoOneDeployment_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "pep-${module.simulatedPaygoOneDeployment.name}"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = data.azurerm_subnet.private_endpoint_subnet.id
  private_connection_resource_id = module.simulatedPaygoOneDeployment.id
  is_manual_connection           = false
  subresource_name               = "account"
  private_dns_zone_group_name    = "OpenAiPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.openai_private_dns_zone.id]
}

module "openai_simulatedPaygoTwoDeployment_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "pep-${module.simulatedPaygoTwoDeployment.name}"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = data.azurerm_subnet.private_endpoint_subnet.id
  private_connection_resource_id = module.simulatedPaygoTwoDeployment.id
  is_manual_connection           = false
  subresource_name               = "account"
  private_dns_zone_group_name    = "OpenAiPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.openai_private_dns_zone.id]
}

module "simulatedPTUDeployment" {
  source                        = "./modules/openai"
  name                          = "ptu-${local.resourceSuffix}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku_name                      = var.openai_sku_name
  deployments                   = var.openai_deployments
  custom_subdomain_name         = lower("${local.resourceSuffix}${var.openai_name}-ptu")
  public_network_access_enabled = var.openai_public_network_access_enabled
  apimIdentityName              = data.azurerm_user_assigned_identity.apimIdentity.name
  apimResourceGroupName         = local.apimResourceGroupName
}

module "simulatedPaygoOneDeployment" {
  source                        = "./modules/openai"
  name                          = "paygo-one-${local.resourceSuffix}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku_name                      = var.openai_sku_name
  deployments                   = var.openai_deployments
  custom_subdomain_name         = lower("${local.resourceSuffix}${var.openai_name}-paygo-one")
  public_network_access_enabled = var.openai_public_network_access_enabled
  apimIdentityName              = data.azurerm_user_assigned_identity.apimIdentity.name
  apimResourceGroupName         = local.apimResourceGroupName
}

module "simulatedPaygoTwoDeployment" {
  source                        = "./modules/openai"
  name                          = "paygo-two-${local.resourceSuffix}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku_name                      = var.openai_sku_name
  deployments                   = var.openai_deployments
  custom_subdomain_name         = lower("${local.resourceSuffix}${var.openai_name}-paygo-two")
  public_network_access_enabled = var.openai_public_network_access_enabled
  apimIdentityName              = data.azurerm_user_assigned_identity.apimIdentity.name
  apimResourceGroupName         = local.apimResourceGroupName
}

module "eventHub" {
  source                  = "./modules/eventhub"
  eventHubName            = var.eventHubName
  eventHubNamespaceName   = local.eventHubNamespaceName
  location                = var.location
  apimIdentityName        = data.azurerm_user_assigned_identity.apimIdentity.name
  apimResourceGroupName   = data.azurerm_resource_group.apim.name
  openaiResourceGroupName = azurerm_resource_group.rg.name
}

module "apiManagement" {
  source                         = "./modules/apim_policies"
  location                       = var.location
  openaiResourceGroupName        = local.openaiResourceGroupName
  resourceGroupName              = local.apimResourceGroupName
  apiManagementServiceName       = local.apimName
  ptuDeploymentOneBaseUrl        = "${module.simulatedPTUDeployment.endpoint}openai"
  payAsYouGoDeploymentOneBaseUrl = "${module.simulatedPaygoOneDeployment.endpoint}openai"
  payAsYouGoDeploymentTwoBaseUrl = "${module.simulatedPaygoTwoDeployment.endpoint}openai"
  eventHubNamespaceName          = module.eventHub.eventHubNamespaceName
  eventHubName                   = module.eventHub.eventHubName
  apimIdentityName               = data.azurerm_user_assigned_identity.apimIdentity.name

  depends_on = [
    module.eventHub
  ]
}
