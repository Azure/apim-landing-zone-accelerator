locals {
  azureOpenAIAPINames = [azurerm_api_management_api.azureOpenAIApi.name]
}

data "azurerm_api_management" "apiManagementService" {
  name                = var.apiManagementServiceName
  resource_group_name = var.resourceGroupName
}

data "azurerm_user_assigned_identity" "apimIdentity" {
  name                = var.apimIdentityName
  resource_group_name = var.resourceGroupName
}

data "azurerm_eventhub_namespace" "eventHubNamespace" {
  name                = var.eventHubNamespaceName
  resource_group_name = var.openaiResourceGroupName
}

resource "azurerm_api_management_api" "azureOpenAIApi" {
  name                = "azure-openai-api"
  resource_group_name = var.resourceGroupName
  api_management_name = data.azurerm_api_management.apiManagementService.name
  revision            = "1"
  display_name        = "AzureOpenAI"
  path                = "openai"
  protocols           = ["https"]

  import {
    content_format = "openapi+json"
    content_value = file("modules/apim_policies/api-specs/openapi-spec.json")
  }
}

resource "azurerm_api_management_product" "azureOpenAIProduct" {
  product_id            = "aoai-product"
  resource_group_name   = var.resourceGroupName
  api_management_name   = data.azurerm_api_management.apiManagementService.name
  display_name          = "aoai-product"
  subscription_required = true
  published             = true
}

resource "azurerm_api_management_product_api" "azureOpenAIProductAPI" {
  # count               = length(local.azureOpenAIAPINames)
  product_id = azurerm_api_management_product.azureOpenAIProduct.product_id
  # api_name            = "${data.azurerm_api_management.apiManagementService.name}/${azurerm_api_management_product.azureOpenAIProduct.display_name}/${local.azureOpenAIAPINames[count.index]}"
  api_name            = azurerm_api_management_api.azureOpenAIApi.name
  api_management_name = data.azurerm_api_management.apiManagementService.name
  resource_group_name = var.resourceGroupName
  depends_on = [
    azurerm_api_management_api.azureOpenAIApi
  ]
}

resource "azurerm_api_management_backend" "ptuBackendOne" {
  name                = "ptu-backend-1"
  resource_group_name = var.resourceGroupName
  api_management_name = data.azurerm_api_management.apiManagementService.name
  protocol            = "http"
  url                 = var.ptuDeploymentOneBaseUrl
}

resource "azurerm_api_management_backend" "payAsYouGoBackendOne" {
  name                = "payg-backend-1"
  resource_group_name = var.resourceGroupName
  api_management_name = data.azurerm_api_management.apiManagementService.name
  protocol            = "http"
  url                 = var.payAsYouGoDeploymentOneBaseUrl
}

resource "azurerm_api_management_backend" "payAsYouGoBackendTwo" {
  name                = "payg-backend-2"
  resource_group_name = var.resourceGroupName
  api_management_name = data.azurerm_api_management.apiManagementService.name
  protocol            = "http"
  url                 = var.payAsYouGoDeploymentTwoBaseUrl
}

resource "azurerm_api_management_subscription" "azureOpenAIProductSubscription" {
  subscription_id     = "aoai-product-subscription"
  resource_group_name = var.resourceGroupName
  api_management_name = data.azurerm_api_management.apiManagementService.name
  display_name        = "aoai-product-subscription"
  state               = "active"
  product_id          = azurerm_api_management_product.azureOpenAIProduct.id
}

resource "azurerm_api_management_policy_fragment" "simpleRoundRobinPolicyFragment" {
  api_management_id = data.azurerm_api_management.apiManagementService.id
  name              = "simple-round-robin"
  format            = "rawxml"
  value             = file("../policies/fragments/load-balancing/simple-round-robin.xml")
  depends_on = [
    azurerm_api_management_backend.payAsYouGoBackendOne,
    azurerm_api_management_backend.payAsYouGoBackendTwo,
    azurerm_api_management_named_value.apimOpenaiApiUamiNamedValue
  ]
}

resource "azurerm_api_management_policy_fragment" "weightedRoundRobinPolicyFragment" {
  api_management_id = data.azurerm_api_management.apiManagementService.id
  name              = "weighted-round-robin"
  format            = "rawxml"
  value             = file("../policies/fragments/load-balancing/weighted-round-robin.xml")
  depends_on = [
    azurerm_api_management_backend.payAsYouGoBackendOne,
    azurerm_api_management_backend.payAsYouGoBackendTwo,
    azurerm_api_management_named_value.apimOpenaiApiUamiNamedValue
  ]
}

resource "azurerm_api_management_policy_fragment" "adaptiveRateLimitingPolicyFragment" {
  api_management_id = data.azurerm_api_management.apiManagementService.id
  name              = "adaptive-rate-limiting"
  format            = "rawxml"
  value             = file("../policies/fragments/rate-limiting/adaptive-rate-limiting.xml")
  depends_on = [
    azurerm_api_management_backend.payAsYouGoBackendOne,
    azurerm_api_management_backend.payAsYouGoBackendTwo
  ]
}

resource "azurerm_api_management_policy_fragment" "adaptiveRateLimitingWorkAroundPolicyFragment" {
  api_management_id = data.azurerm_api_management.apiManagementService.id
  name              = "adaptive-rate-limiting-workaround"
  format            = "rawxml"
  value             = file("../policies/fragments/rate-limiting/adaptive-rate-limiting-workaround.xml")
  depends_on = [
    azurerm_api_management_backend.payAsYouGoBackendOne,
    azurerm_api_management_backend.payAsYouGoBackendTwo
  ]
}

resource "azurerm_api_management_policy_fragment" "retryWithPayAsYouGoPolicyFragment" {
  api_management_id = data.azurerm_api_management.apiManagementService.id
  name              = "retry-with-payg"
  format            = "rawxml"
  value             = file("../policies/fragments/manage-spikes-with-payg/retry-with-payg.xml")
}

resource "azurerm_api_management_policy_fragment" "usageTrackingEHPolicyFragment" {
  api_management_id = data.azurerm_api_management.apiManagementService.id
  name              = "usage-tracking-with-eventhub"
  format            = "rawxml"
  value             = file("../policies/fragments/usage-tracking/usage-tracking-with-eventhub.xml")
  depends_on = [
    azurerm_api_management_logger.event_hub_logger
  ]
}

resource "azurerm_api_management_policy_fragment" "usageTrackingWithAppInsightsPolicyFragment" {
  api_management_id = data.azurerm_api_management.apiManagementService.id
  name              = "usage-tracking-with-appinsights"
  format            = "rawxml"
  value             = file("../policies/fragments/usage-tracking/usage-tracking-with-appinsights.xml")
  depends_on = [
    azurerm_api_management_logger.event_hub_logger
  ]
}

resource "azurerm_api_management_api_policy" "azureOpenAIApiPolicy" {
  api_name            = azurerm_api_management_api.azureOpenAIApi.name
  api_management_name = data.azurerm_api_management.apiManagementService.name
  resource_group_name = data.azurerm_api_management.apiManagementService.resource_group_name
  xml_content         = file("../policies/genai-policy.xml")
  depends_on = [
    azurerm_api_management_policy_fragment.simpleRoundRobinPolicyFragment,
    azurerm_api_management_policy_fragment.weightedRoundRobinPolicyFragment,
    azurerm_api_management_policy_fragment.adaptiveRateLimitingPolicyFragment,
    azurerm_api_management_policy_fragment.retryWithPayAsYouGoPolicyFragment,
    azurerm_api_management_policy_fragment.usageTrackingWithAppInsightsPolicyFragment
  ]
}

resource "azurerm_api_management_named_value" "apimOpenaiApiUamiNamedValue" {
  name                = "apim-identity"
  resource_group_name = var.resourceGroupName
  api_management_name = data.azurerm_api_management.apiManagementService.name
  display_name        = "apim-identity"
  # value               = var.apimIdentityName
  value               = data.azurerm_user_assigned_identity.apimIdentity.client_id
  secret              = true
}

resource "azurerm_api_management_logger" "event_hub_logger" {
  name                = "eventhub-logger"
  resource_group_name = var.resourceGroupName
  api_management_name = data.azurerm_api_management.apiManagementService.name
  eventhub {
    name              = var.eventHubName
    connection_string = data.azurerm_eventhub_namespace.eventHubNamespace.default_primary_connection_string
  }
}
