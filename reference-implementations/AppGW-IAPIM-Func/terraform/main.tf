
resource "azurerm_resource_group" "hub_rg" {
  name     = "hub-rg-002"
  location = "East US"
}

module "networking" {
  source = "./networking"

  workload_name             = "pm-t"
  resource_group_name       = azurerm_resource_group.hub_rg.name
  resource_group_location   = azurerm_resource_group.hub_rg.location
  deployment_environment    = "dev"
}

#-------------------------------
# Calling the APIM module
#-------------------------------

module "apim" {
  source = "./apim"
  workspace_id = module.shared.workspace_id
  instrumentation_key = module.shared.instrumentation_key
  apim_subnet_id = module.networking.apim_subnet_id
  workload_name = var.workload_name
}

module "shared" {
  source = "./shared"
  workload_name = var.workload_name
}
