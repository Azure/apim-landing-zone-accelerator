resource "azurerm_eventhub_namespace" "eventHubNamespace" {
  name                 = var.eventHubNamespaceName
  location             = var.location
  resource_group_name  = var.openaiResourceGroupName
  sku                  = var.eventHubSku
  capacity             = 1
  auto_inflate_enabled = false
}

resource "azurerm_eventhub" "eventHub" {
  name                = var.eventHubName
  namespace_name      = azurerm_eventhub_namespace.eventHubNamespace.name
  resource_group_name = var.openaiResourceGroupName
  partition_count     = 1
  message_retention   = 7
}

data "azurerm_user_assigned_identity" "apimIdentity" {
  name                = var.apimIdentityName
  resource_group_name = var.apimResourceGroupName
}

data "azurerm_role_definition" "eventHubsDataSenderRoleDefinition" {
  name = "Azure Event Hubs Data Sender"
}

resource "azurerm_role_assignment" "assignEventHubsDataSenderToApiManagement" {
  scope                = azurerm_eventhub_namespace.eventHubNamespace.id
  role_definition_name = data.azurerm_role_definition.eventHubsDataSenderRoleDefinition.name
  principal_id         = data.azurerm_user_assigned_identity.apimIdentity.principal_id
}
