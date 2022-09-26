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


#-------------------------------
# Creation of a key vault instance
#-------------------------------

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                        = trim(substr("kv-${var.resource_suffix}", 0, 24), "-")
  location                    = azurerm_resource_group.shared_rg.location
  resource_group_name         = azurerm_resource_group.shared_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.key_vault_sku

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
    certificate_permissions = [
      "import",
      "get",
      "list",
      "update",
      "create"
    ]
  }
}