locals {
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
}