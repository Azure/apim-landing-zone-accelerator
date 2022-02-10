locals {
<<<<<<< HEAD
  resource_suffix = "${var.workload_name}-${var.environment}-${var.location}-001"
}

#-------------------------------
# Shared Resource group creation
#-------------------------------
resource "azurerm_resource_group" "shared_rg" {
  name     = "rg-shared-${local.resource_suffix}"
  location = var.location
}

#-------------------------------
# Creation of log analytics workspace instance 
#-------------------------------

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "laws-${local.resource_suffix}"
  location            = azurerm_resource_group.shared_rg.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

#-------------------------------
# Creation of an application inisight instance 
#-------------------------------

resource "azurerm_application_insights" "shared_apim_insight" {
  name                = "appi-${local.resource_suffix}"
  location            = azurerm_resource_group.shared_rg.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
=======
    key_vault_name = substr("kv-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}-${var.resource_suffix}", 0, 24)
}

resource "azurerm_key_vault" "example" {
  name                        = local.key_vault_name
  location                    = var.resource_group_location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
>>>>>>> bd02ef0664f50b136832909aca0bedca4e7213c0
}