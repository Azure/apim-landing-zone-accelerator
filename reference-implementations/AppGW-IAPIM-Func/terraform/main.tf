locals {
  resource_suffix = "001"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "hub_rg" {
  name     = "hub-rg-002"
  location = "East US"
}

module "shared" {
  source = "./shared"

  tenant_id                 = data.azurerm_client_config.current.tenant_id
  resource_group_name       = azurerm_resource_group.hub_rg.name
  resource_group_location   = azurerm_resource_group.hub_rg.location
  workload_name             = "pm-t"
  resource_suffix           = local.resource_suffix
  deployment_environment    = "dev"
}

module "networking" {
  source = "./networking"

  resource_group_name       = azurerm_resource_group.hub_rg.name
  resource_group_location   = azurerm_resource_group.hub_rg.location
  workload_name             = "pm-t"
  deployment_environment    = "dev"
}

#-------------------------------
# calling the APIM module
#-------------------------------

module "apim" {
  source = "./apim"
  workspace_id = module.shared.workspace_id
  instrumentation_key = module.shared.instrumentation_key
  apim_subnet_id = module.networking.apim_subnet_id
  workload_name = var.workload_name
}

#-------------------------------
# calling the shared module
#-------------------------------
module "shared" {
  source = "./shared"
  workload_name = var.workload_name
}
