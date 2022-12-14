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
  name                = trim(substr("kv-${var.resource_suffix}", 0, 24), "-")
  location            = azurerm_resource_group.shared_rg.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku
}

locals {
  deployment_client_ids = toset(
    concat(
      [data.azurerm_client_config.current.object_id],
      var.additional_client_ids
    )
  )
}

# created as a seperate resource, as managed identity uses the azurerm_key_vault_access_policy as well. See note at https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy
resource "azurerm_key_vault_access_policy" "deployment_spn_access_policy" {
  for_each     = local.deployment_client_ids
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

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
    "Import",
    "Get",
    "List",
    "Update",
    "Create"
  ]
}