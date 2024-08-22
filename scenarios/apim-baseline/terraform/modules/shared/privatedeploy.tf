
resource "azurerm_storage_account" "privatedeploystorage" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = var.resourceGroupName
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    bypass         = ["AzureServices"]
    default_action = "Deny"

    virtual_network_subnet_ids = [
      var.deploymentSubnetId
    ]
  }
}

# Resource: User Assigned Identity
resource "azurerm_user_assigned_identity" "privatedeploymanagedidentity" {
  name                = "mi-deploy-${var.resourceSuffix}"
  location            = var.location
  resource_group_name = var.resourceGroupName
}

# Resource: Role Assignment
resource "azurerm_role_assignment" "privatedeploystorageroleassignment" {
  scope                = azurerm_storage_account.privatedeploystorage.id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azurerm_user_assigned_identity.privatedeploymanagedidentity.principal_id
}
