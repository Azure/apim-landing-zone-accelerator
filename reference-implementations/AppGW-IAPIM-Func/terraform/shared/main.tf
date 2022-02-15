#-------------------------------
# Shared Resource group creation
#-------------------------------
resource "azurerm_resource_group" "shared_rg" {
  name     = "rg-shared-${var.resource_suffix}"
  location = var.location
}

#-------------------------------
# Creation of log analytics workspace instance 
#-------------------------------

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "log-${var.resource_suffix}"
  location            = azurerm_resource_group.shared_rg.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

#-------------------------------
# Creation of an application inisight instance 
#-------------------------------

resource "azurerm_application_insights" "shared_apim_insight" {
  name                = "appi-${var.resource_suffix}"
  location            = azurerm_resource_group.shared_rg.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
}


# Note: This needs to be updated as the resource name is 'example' and the name does not match with the naming convention
resource "azurerm_key_vault" "key_vault" {
  name                        = "kv-${var.resource_suffix}"
  location                    = azurerm_resource_group.shared_rg.location
  resource_group_name         = azurerm_resource_group.shared_rg.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
}