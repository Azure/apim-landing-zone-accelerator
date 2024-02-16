#-------------------------------
# APIM Resource group creation
#-------------------------------
resource "azurerm_resource_group" "apim_internal_rg" {
  name     = "rg-apim-${var.resource_suffix}"
  location = var.location
}

#-------------------------------
# Creation of an internal APIM instance 
#-------------------------------
resource "azurerm_api_management" "apim_internal" {
  name                 = "apim-${var.resource_suffix}"
  location             = azurerm_resource_group.apim_internal_rg.location
  resource_group_name  = azurerm_resource_group.apim_internal_rg.name
  publisher_name       = var.publisher_name
  publisher_email      = var.publisher_email
  virtual_network_type = "Internal"

  sku_name = var.sku_name

  virtual_network_configuration {
    subnet_id = var.apim_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }
}


#-------------------------------
# Creation of the apim logger entity
#-------------------------------
resource "azurerm_api_management_logger" "apim_logger" {
  name                = "apim-logger"
  api_management_name = azurerm_api_management.apim_internal.name
  resource_group_name = azurerm_resource_group.apim_internal_rg.name
  resource_id         = var.workspace_id


  application_insights {
    instrumentation_key = var.instrumentation_key
  }
}

#-------------------------------
# API management service diagnostic
#-------------------------------
resource "azurerm_api_management_diagnostic" "apim_diagnostic" {
  identifier               = "applicationinsights"
  resource_group_name      = azurerm_resource_group.apim_internal_rg.name
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
}