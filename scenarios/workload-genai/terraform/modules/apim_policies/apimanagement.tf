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
    content_value  = file("modules/apim_policies/api-specs/openapi-spec.json")
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

resource "azurerm_api_management_product" "multiTenantProduct1" {
  product_id            = "multi-tenant-product1"
  resource_group_name   = var.resourceGroupName
  api_management_name   = data.azurerm_api_management.apiManagementService.name
  display_name          = "multi-tenant-product1"
  subscription_required = true
  published             = true
}

resource "azurerm_api_management_product" "multiTenantProduct2" {
  product_id            = "multi-tenant-product2"
  resource_group_name   = var.resourceGroupName
  api_management_name   = data.azurerm_api_management.apiManagementService.name
  display_name          = "multi-tenant-product2"
  subscription_required = true
  published             = true
}

resource "azurerm_api_management_product_api" "azureOpenAIProductAPI" {
  product_id          = azurerm_api_management_product.azureOpenAIProduct.product_id
  api_name            = azurerm_api_management_api.azureOpenAIApi.name
  api_management_name = data.azurerm_api_management.apiManagementService.name
  resource_group_name = var.resourceGroupName
  depends_on = [
    azurerm_api_management_api.azureOpenAIApi,
    azurerm_api_management_policy_fragment.simpleRoundRobinPolicyFragment
  ]
}

resource "azurerm_api_management_product_api" "multiTenantProduct1API" {
  product_id          = azurerm_api_management_product.multiTenantProduct1.product_id
  api_name            = azurerm_api_management_api.azureOpenAIApi.name
  api_management_name = data.azurerm_api_management.apiManagementService.name
  resource_group_name = var.resourceGroupName
  depends_on = [
    azurerm_api_management_api.azureOpenAIApi,
    azurerm_api_management_policy_fragment.simpleRoundRobinPolicyFragment
  ]
}

resource "azurerm_api_management_product_api" "multiTenantProduct2API" {
  product_id          = azurerm_api_management_product.multiTenantProduct2.product_id
  api_name            = azurerm_api_management_api.azureOpenAIApi.name
  api_management_name = data.azurerm_api_management.apiManagementService.name
  resource_group_name = var.resourceGroupName
  depends_on = [
    azurerm_api_management_api.azureOpenAIApi,
    azurerm_api_management_policy_fragment.simpleRoundRobinPolicyFragment
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

resource "azurerm_api_management_subscription" "multiTenantProduct1Subscription" {
  subscription_id     = "multi-tenant-product1-subscription"
  resource_group_name = var.resourceGroupName
  api_management_name = data.azurerm_api_management.apiManagementService.name
  display_name        = "multi-tenant-product1-subscription"
  state               = "active"
  product_id          = azurerm_api_management_product.multiTenantProduct1.id
}

resource "azurerm_api_management_subscription" "multiTenantProduct2Subscription" {
  subscription_id     = "multi-tenant-product2-subscription"
  resource_group_name = var.resourceGroupName
  api_management_name = data.azurerm_api_management.apiManagementService.name
  display_name        = "multi-tenant-product2-subscription"
  state               = "active"
  product_id          = azurerm_api_management_product.multiTenantProduct2.id
}

resource "azurerm_api_management_policy_fragment" "simpleRoundRobinPolicyFragment" {
  api_management_id = data.azurerm_api_management.apiManagementService.id
  name              = "simple-priority-weighted"
  format            = "rawxml"
  value             = file("../policies/fragments/load-balancing/simple-priority-weighted.xml")
  depends_on = [
    azurerm_api_management_backend.payAsYouGoBackendOne,
    azurerm_api_management_backend.payAsYouGoBackendTwo,
    azurerm_api_management_named_value.apimOpenaiApiUamiNamedValue,
    module.api_lb_pool
  ]
}

resource "azurerm_api_management_policy_fragment" "simpleRateLimitingPolicyFragment" {
  api_management_id = data.azurerm_api_management.apiManagementService.id
  name              = "rate-limiting-by-tokens"
  format            = "rawxml"
  value             = file("../policies/fragments/rate-limiting/rate-limiting-by-tokens.xml")
  depends_on = [
    azurerm_api_management_backend.payAsYouGoBackendOne,
    azurerm_api_management_backend.payAsYouGoBackendTwo
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
  name              = "rate-limiting-workaround"
  format            = "rawxml"
  value             = file("../policies/fragments/rate-limiting/rate-limiting-workaround.xml")
  depends_on = [
    azurerm_api_management_backend.payAsYouGoBackendOne,
    azurerm_api_management_backend.payAsYouGoBackendTwo
  ]
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

//Load-balancing with Circuit Breaker policy
module "api_backend" {
  source                      = "./backends"
  api_management_service_name = data.azurerm_api_management.apiManagementService.name
  backend_uris = [
    "${var.ptuDeploymentOneBaseUrl}/",
    "${var.payAsYouGoDeploymentOneBaseUrl}/",
    "${var.payAsYouGoDeploymentTwoBaseUrl}/"
  ]
  resource_group_name = var.resourceGroupName
  depends_on = [
    data.azurerm_api_management.apiManagementService
  ]
}

module "api_lb_pool" {
  source                      = "./lb_pool"
  api_management_service_name = data.azurerm_api_management.apiManagementService.name
  backends                    = module.api_backend.backend_names
  resource_group_name         = var.resourceGroupName
  depends_on = [
    module.api_backend
  ]
}

resource "azurerm_api_management_api_policy" "azureOpenAIApiPolicy" {
  api_name            = azurerm_api_management_api.azureOpenAIApi.name
  api_management_name = data.azurerm_api_management.apiManagementService.name
  resource_group_name = data.azurerm_api_management.apiManagementService.resource_group_name
  xml_content         = file("../policies/genai-policy.xml")
  depends_on = [
    azurerm_api_management_policy_fragment.simpleRoundRobinPolicyFragment,
    azurerm_api_management_policy_fragment.adaptiveRateLimitingPolicyFragment,
    azurerm_api_management_policy_fragment.usageTrackingWithAppInsightsPolicyFragment
  ]
}

resource "azurerm_api_management_product_policy" "multiTenantProduct1Policy" {
  product_id          = azurerm_api_management_product.multiTenantProduct1.product_id
  api_management_name = data.azurerm_api_management.apiManagementService.name
  resource_group_name = data.azurerm_api_management.apiManagementService.resource_group_name
  xml_content         = file("../policies/multi-tenancy/multi-tenant-product1-policy.xml")
}

resource "azurerm_api_management_product_policy" "multiTenantProduct2Policy" {
  product_id          = azurerm_api_management_product.multiTenantProduct2.product_id
  api_management_name = data.azurerm_api_management.apiManagementService.name
  resource_group_name = data.azurerm_api_management.apiManagementService.resource_group_name
  xml_content         = file("../policies/multi-tenancy/multi-tenant-product2-policy.xml")
}

resource "azurerm_api_management_named_value" "apimOpenaiApiUamiNamedValue" {
  name                = "apim-identity"
  resource_group_name = var.resourceGroupName
  api_management_name = data.azurerm_api_management.apiManagementService.name
  display_name        = "apim-identity"
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
