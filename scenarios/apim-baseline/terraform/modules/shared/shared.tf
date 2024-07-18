data "azurerm_client_config" "current" {}

#-------------------------------
# Creation of a key vault instance
#-------------------------------

resource "azurerm_key_vault" "key_vault" {
  name = trim(substr("kv-${var.resourceSuffix}", 0, 24), "-")
  # name                = "kv-apimdemo-dev-m2b"
  location            = var.location
  resource_group_name = var.resourceGroupName
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.keyVaultSku
}

locals {
  deployment_client_ids = toset(
    concat(
      [data.azurerm_client_config.current.object_id],
      var.additionalClientIds
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
