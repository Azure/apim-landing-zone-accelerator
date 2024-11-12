locals {
  apimName          = "apim-${var.resourceSuffix}"
  apimPipPrimaryPip = "pip-apim-${var.resourceSuffix}"
  apimIdentityName  = "identity-${local.apimName}"
}

resource "azurerm_user_assigned_identity" "apimIdentity" {
  name                = local.apimIdentityName
  location            = var.location
  resource_group_name = var.resourceGroupName
}

data "azurerm_key_vault" "keyVault" {
  name                = var.keyVaultName
  resource_group_name = var.sharedResourceGroupName
}

#-------------------------------
# Creation of an internal APIM instance
#-------------------------------
resource "azurerm_api_management" "apim_internal" {
  name                 = local.apimName
  location             = var.location
  resource_group_name  = var.resourceGroupName
  publisher_name       = var.publisherName
  publisher_email      = var.publisherEmail
  virtual_network_type = "Internal"

  sku_name = var.skuName

  min_api_version = "2019-12-01"

  virtual_network_configuration {
    subnet_id = var.apimSubnetId
  }

  identity {
    type         = "UserAssigned"
    identity_ids = ["${azurerm_user_assigned_identity.apimIdentity.id}"]
  }

  lifecycle {
    prevent_destroy = true
  }
}


#-------------------------------
# Creation of the apim logger entity
#-------------------------------
resource "azurerm_api_management_logger" "apim_logger" {
  name                = "apim-logger"
  api_management_name = azurerm_api_management.apim_internal.name
  resource_group_name = var.resourceGroupName
  resource_id         = var.workspaceId

  application_insights {
    instrumentation_key = var.instrumentationKey
  }

  lifecycle {
    prevent_destroy = true
  }
}

#-------------------------------
# API management service diagnostic
#-------------------------------
resource "azurerm_api_management_diagnostic" "apim_diagnostic" {
  identifier               = "applicationinsights"
  resource_group_name      = var.resourceGroupName
  api_management_name      = azurerm_api_management.apim_internal.name
  api_management_logger_id = azurerm_api_management_logger.apim_logger.id

  sampling_percentage = 100.0
  always_log_errors   = true
  verbosity           = "verbose" #possible value are verbose, error, information


  frontend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  frontend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }

  backend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  backend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_api_management_product" "starter" {
  display_name        = "Starter"
  product_id          = "starter"
  api_management_name = azurerm_api_management.apim_internal.name
  resource_group_name = azurerm_api_management.apim_internal.resource_group_name
  published           = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_uuid" "starter_key" {
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_api_management_subscription" "echo" {
  api_management_name = azurerm_api_management.apim_internal.name
  resource_group_name = azurerm_api_management.apim_internal.resource_group_name
  product_id          = azurerm_api_management_product.starter.id
  display_name        = "Echo API"
  primary_key         = random_uuid.starter_key.result
  allow_tracing       = false
  state               = "active"

  lifecycle {
    prevent_destroy = true
  }
}

#-------------------------------
# Importing the Echo API into API Management
#-------------------------------
resource "azurerm_api_management_api" "echo_api" {
  name                = "echo-api"
  api_management_name = azurerm_api_management.apim_internal.name
  resource_group_name = azurerm_api_management.apim_internal.resource_group_name
  revision            = "1"
  display_name        = "Echo API"
  path                = "echo"
  protocols           = ["https"]
  service_url         = "http://echoapi.cloudapp.net/api"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_api_management_api_operation" "echo_api_operation" {
  api_name            = azurerm_api_management_api.echo_api.name
  api_management_name = azurerm_api_management.apim_internal.name
  resource_group_name = azurerm_api_management.apim_internal.resource_group_name
  display_name        = "Retrieve resource"
  method              = "GET"
  url_template        = "/resource"

  request {
    query_parameter {
      type          = "string"
      name          = "param1"
      default_value = "sample"
      required      = true
    }
    query_parameter {
      type     = "number"
      name     = "param2"
      required = false
    }
  }

  response {
    status_code = 200
    description = "A demonstration of a GET call on a sample resource. It is handled by an \"echo\" backend which returns a response equal to the request (the supplied headers and body are being returned as received)."
  }
  operation_id = "retrieve-resource"

  lifecycle {
    prevent_destroy = true
  }

}

resource "azurerm_api_management_product_api" "echo" {
  api_name            = azurerm_api_management_api.echo_api.name
  product_id          = azurerm_api_management_product.starter.product_id
  api_management_name = azurerm_api_management.apim_internal.name
  resource_group_name = azurerm_api_management.apim_internal.resource_group_name

  lifecycle {
    prevent_destroy = true
  }
}


resource "azurerm_key_vault_access_policy" "apim_access_policy" {
  key_vault_id = data.azurerm_key_vault.keyVault.id
  tenant_id    = azurerm_user_assigned_identity.apimIdentity.tenant_id
  object_id    = azurerm_user_assigned_identity.apimIdentity.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  certificate_permissions = [
    "Get",
    "List"
  ]
}
