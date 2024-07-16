locals {
  # resourceSuffix              = "${var.workloadName}-${var.environment}-${var.location}-${random_string.random_identifier.result}"
  resourceSuffix              = "${var.workloadName}-${var.environment}-${var.location}-m2b"
  networkingResourceGroupName = "rg-networking-${local.resourceSuffix}"
  # sharedResourceGroupName     = "rg-shared-${local.resourceSuffix}"
  apimResourceGroupName        = "rg-apim-${local.resourceSuffix}"
  apimName                     = "apim-${local.resourceSuffix}"
  openaiResourceGroupName      = "rg-openai-${local.resourceSuffix}"
  apim_cs_vnet_name            = "vnet-apim-cs-${local.resourceSuffix}"
  deploy_subnet_name           = "snet-deploy-${local.resourceSuffix}"
  private_endpoint_subnet_name = "snet-prep-${local.resourceSuffix}"
  eventHubNamespaceName        = "eh-ns-${local.resourceSuffix}"
}

data "azurerm_client_config" "current" {
}

# data retrieve apim resource
data "azurerm_api_management" "apim" {
  name                = local.apimName
  resource_group_name = local.apimResourceGroupName
}


resource "random_string" "random_identifier" {
  length  = 3
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = local.openaiResourceGroupName
  location = var.location
}

data "azurerm_resource_group" "networking" {
  name = local.networkingResourceGroupName
}

data "azurerm_resource_group" "apim" {
  name = local.apimResourceGroupName
  # location = var.location
}

# module "log_analytics_workspace" {
#   source                           = "./modules/log_analytics"
#   name                             = "${local.resourceSuffix}${var.log_analytics_workspace_name}"
#   location                         = var.location
#   resource_group_name              = azurerm_resource_group.rg.name
# }

# resource "azurerm_virtual_network" "apim_cs_vnet" {
#   name                = local.apim_cs_vnet_name
#   location            = var.location
#   resource_group_name = azurerm_resource_group.networking.name
#   address_space       = var.vnet_address_space
# }

# resource "azurerm_subnet" "deploy_subnet" {
#   name                 = local.deploy_subnet_name
#   resource_group_name  = azurerm_resource_group.networking.name
#   virtual_network_name = azurerm_virtual_network.apim_cs_vnet.name
#   address_prefixes     = [var.privateEndpointAddressPrefix]
# }

# module "virtual_network" {
#   source                           = "./modules/virtual_network"
#   resource_group_name              = azurerm_resource_group.networking.name
#   vnet_name                        = local.apim_cs_vnet_name
#   location                         = var.location
#   address_space                    = var.vnet_address_space
#   tags                             = var.tags
#   log_analytics_workspace_id       = module.log_analytics_workspace.id

#   subnets = [
#     {
#       name : var.aca_subnet_name
#       address_prefixes : var.aca_subnet_address_prefix
#       private_endpoint_network_policies_enabled : true
#       private_link_service_network_policies_enabled : false
#     },
#     {
#       name : var.private_endpoint_subnet_name
#       address_prefixes : var.private_endpoint_subnet_address_prefix
#       private_endpoint_network_policies_enabled : true
#       private_link_service_network_policies_enabled : false
#     }
#   ]
# }

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

module "openai_private_dns_zone" {
  source                      = "./modules/private_dns_zone"
  name                        = "privatelink.openai.azure.com"
  resource_group_name         = azurerm_resource_group.rg.name
  virtual_networks_to_link_id = data.azurerm_virtual_network.apim_cs_vnet.id
  # virtual_networks_to_link = {
  #   (local.apim_cs_vnet_name) = {
  #     subscription_id     = data.azurerm_client_config.current.subscription_id
  #     resource_group_name = azurerm_resource_group.rg.name
  #   }
  # }
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
}

module "eventHub" {
  source                  = "./modules/eventhub"
  eventHubName            = var.eventHubName
  eventHubNamespaceName   = local.eventHubNamespaceName
  location                = var.location
  apimIdentityName        = data.azurerm_api_management.apim.identity[0].principal_id
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
  apimIdentityName               = data.azurerm_api_management.apim.identity[0].principal_id

  depends_on = [
    module.eventHub
  ]
}
