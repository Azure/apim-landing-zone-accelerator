locals {
    key_vault_name = substr("kv-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}-${var.resource_suffix}", 0, 24)
}

resource "azurerm_key_vault" "example" {
  name                        = local.key_vault_name
  location                    = var.resource_group_location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
}