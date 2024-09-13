data "azurerm_user_assigned_identity" "apimIdentity" {
  name                = var.apimIdentityName
  resource_group_name = var.apimResourceGroupName
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_cognitive_account" "openai" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  kind                          = "OpenAI"
  custom_subdomain_name         = var.custom_subdomain_name
  sku_name                      = var.sku_name
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_cognitive_deployment" "deployment" {
  for_each = { for deployment in var.deployments : deployment.name => deployment }

  name                 = each.key
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = each.value.model.name
    version = each.value.model.version
  }

  scale {
    type = "Standard"
  }
}

data "azurerm_role_definition" "cognitiveServicesOpenAIUser" {
  name  = "Cognitive Services OpenAI User"
  scope = data.azurerm_subscription.primary.id
}

resource "azurerm_role_assignment" "roleAssignment" {
  scope              = azurerm_cognitive_account.openai.id
  role_definition_id = data.azurerm_role_definition.cognitiveServicesOpenAIUser.id
  principal_id       = data.azurerm_user_assigned_identity.apimIdentity.principal_id
}
