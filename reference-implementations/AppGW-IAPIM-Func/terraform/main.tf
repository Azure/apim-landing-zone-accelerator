locals {
  resource_location = lower(replace(var.location, " ", ""))
}

data "azurerm_client_config" "current" {
}

#-------------------------------
# calling the Resource Naming   module
#-------------------------------
module "resource_suffix" {
  source = "./modules/service-suffix"

  workload_name           = var.workload_name
  deployment_environment  = var.deployment_environment
  location                = local.resource_location
  resource_suffix         = var.resource_suffix
}

#-------------------------------
# calling the Shared module
#-------------------------------
module "shared" {
  source = "./shared"

  tenant_id       = data.azurerm_client_config.current.tenant_id
  resource_suffix = module.resource_suffix.name
  location        = local.resource_location
}

#-------------------------------
# calling the Network module
#-------------------------------
module "networking" {
  source = "./networking"

  location                  = local.resource_location
  workload_name             = var.workload_name
  deployment_environment    = var.deployment_environment
}

#-------------------------------
# calling the APIM module
#-------------------------------
module "apim" {
  source = "./apim"

  resource_suffix     = var.resource_suffix
  workspace_id        = module.shared.workspace_id
  instrumentation_key = module.shared.instrumentation_key
  apim_subnet_id      = module.networking.apim_subnet_id
}

#-------------------------------
# calling the App Gateway module
#-------------------------------
module "application_gateway" {
  source = "./gateway"

  resource_suffix           = var.resource_suffix
  resource_group_name       = module.apim.apim_resource_group_name
  resource_group_location   = module.apim.apim_resource_group_location
  secret_name               = var.certificate_secret_name
  keyvault_id               = module.shared.key_vault_id
  certificate_path          = var.certificate_path
  certificate_password      = var.certificate_password
  fqdn                      = var.app_gateway_fqdn
  primary_backendend_fqdn   = "${module.apim.name}.azure-api.net"
  subnet_id                 = module.networking.appgateway_subnet_id
}