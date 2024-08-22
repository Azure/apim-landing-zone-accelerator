data "azurerm_client_config" "current" {}

#-------------------------------
# Creation of a key vault instance
#-------------------------------

resource "azurerm_key_vault" "key_vault" {
  name                = var.keyVaultName
  location            = var.location
  resource_group_name = var.resourceGroupName
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.keyVaultSku
  # -> Bicep has keyvault as private, should we change this?
  # -> This will need the certificate to be created through a azurerm_template_deployment resource
  public_network_access_enabled = false
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}

locals {
  # deployment_client_ids = toset(
  #   concat(
  #     [data.azurerm_client_config.current.object_id],
  #     var.additionalClientIds
  #   )
  # )
  privateEndpoint_keyvault_Name = "pep-kv-${var.resourceSuffix}"
  apim_cs_vnet_name             = "vnet-apim-cs-${var.resourceSuffix}"
  networkingResourceGroupName   = "rg-networking-${var.resourceSuffix}"
  private_endpoint_subnet_name  = "snet-prep-${var.resourceSuffix}"
}

# created as a seperate resource, as managed identity uses the azurerm_key_vault_access_policy as well. See note at https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy
resource "azurerm_key_vault_access_policy" "deployment_spn_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

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

data "azurerm_virtual_network" "apim_cs_vnet" {
  name                = local.apim_cs_vnet_name
  resource_group_name = local.networkingResourceGroupName
}

data "azurerm_subnet" "private_endpoint_subnet" {
  name                 = local.private_endpoint_subnet_name
  resource_group_name  = local.networkingResourceGroupName
  virtual_network_name = local.apim_cs_vnet_name
}

module "keyvault_dns_zone" {
  source                      = "./private_dns_zone"
  name                        = "privatelink.vaultcore.azure.net"
  resource_group_name         = local.networkingResourceGroupName
  virtual_networks_to_link_id = data.azurerm_virtual_network.apim_cs_vnet.id
}

module "keyvault_private_endpoint" {
  source                         = "./private_endpoint"
  name                           = local.privateEndpoint_keyvault_Name
  location                       = var.location
  resource_group_name            = local.networkingResourceGroupName
  subnet_id                      = data.azurerm_subnet.private_endpoint_subnet.id
  private_connection_resource_id = azurerm_key_vault.key_vault.id
  is_manual_connection           = false
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.keyvault_dns_zone.id]
}
