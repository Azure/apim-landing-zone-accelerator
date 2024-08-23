variable "api_management_service_name" {
  type = string
}

variable "backends" {
  type = list(string)
}

# variable "backendUris" {
#   type = list(string)
# }

variable "resource_group_name" {
  type = string
}

data "azurerm_api_management" "apiManagementService" {
  name                = var.api_management_service_name
  resource_group_name = var.resource_group_name
}
resource "azapi_resource" "aoai_lb_pool" {
  type      = "Microsoft.ApiManagement/service/backends@2023-09-01-preview"
  name      = "aoai-lb-pool"
  parent_id = data.azurerm_api_management.apiManagementService.id

  schema_validation_enabled = false
  body = jsonencode({
    properties = {
      title = "aoai-lb-pool"
      type  = "Pool"
      pool = {
        services = [
          {
            id       = "/backends/${var.backends[0]}"
            priority = 1
            weight   = 1
          },
          {
            id       = "/backends/${var.backends[1]}"
            priority = 2
            weight   = 2
          },
          {
            id       = "/backends/${var.backends[2]}"
            priority = 1
            weight   = 3
          }
        ]
      }
    }
  })
}
