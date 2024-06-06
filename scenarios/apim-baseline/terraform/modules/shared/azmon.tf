#-------------------------------
# Creation of log analytics workspace instance
#-------------------------------

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "log-${var.resourceSuffix}"
  location            = var.location
  resource_group_name = var.resourceGroupName
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

#-------------------------------
# Creation of an application inisight instance
#-------------------------------

resource "azurerm_application_insights" "shared_apim_insight" {
  name                = "appi-${var.resourceSuffix}"
  location            = var.location
  resource_group_name = var.resourceGroupName
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
}
