locals {
  resource_location = lower(replace(var.location, " ", ""))
}

#-------------------------------
# calling the Resource Naming module
#-------------------------------
module "resource_suffix" {
  source                 = "./modules/service-suffix"
  workload_name          = var.workload_name
  deployment_environment = var.deployment_environment
  location               = local.resource_location
  resource_suffix        = var.resource_suffix
}

#-------------------------------
# calling the Shared module
#-------------------------------
module "shared" {
  source               = "./shared"
  resource_suffix      = module.resource_suffix.name
  location             = local.resource_location
  environment          = var.deployment_environment
  jumpbox_subnet_id    = module.networking.jumpbox_subnet_id
  cicd_agent_subnet_id = module.networking.cicd_agent_subnet_id
  cicd_agent_type      = var.cicd_agent_type
  private_ip_address   = module.apim.private_ip_addresses
  apim_name            = module.apim.name
}

#-------------------------------
# calling the Network module
#-------------------------------
module "networking" {
  source                 = "./networking"
  location               = local.resource_location
  workload_name          = var.workload_name
  deployment_environment = var.deployment_environment
}

#-------------------------------
# calling the APIM module
#-------------------------------
module "apim" {
  source              = "./apim"
  resource_suffix     = module.resource_suffix.name
  location            = local.resource_location
  workspace_id        = module.shared.workspace_id
  instrumentation_key = module.shared.instrumentation_key
  apim_subnet_id      = module.networking.apim_subnet_id
}

#-------------------------------
# calling the App Gateway module
#-------------------------------
module "application_gateway" {
  source                  = "./gateway"
  resource_suffix         = var.resource_suffix
  resource_group_name     = module.apim.apim_resource_group_name
  resource_group_location = module.apim.apim_resource_group_location
  secret_name             = var.certificate_secret_name
  keyvault_id             = module.shared.key_vault_id
  certificate_path        = var.certificate_path
  certificate_password    = var.certificate_password
  fqdn                    = var.app_gateway_fqdn
  primary_backendend_fqdn = "${module.apim.name}.azure-api.net"
  subnet_id               = module.networking.appgateway_subnet_id
}

#-------------------------------
# Calling the Backend module
#-------------------------------
module "backend" {
  source            = "./backend"
  resource_suffix   = module.resource_suffix.name
  workload_name     = var.workload_name
  os_type           = var.os_type
  location          = local.resource_location
  backend_subnet_id = module.networking.backend_subnet_id
}
