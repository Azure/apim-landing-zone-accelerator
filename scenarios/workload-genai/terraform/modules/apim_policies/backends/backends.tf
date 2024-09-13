variable "api_management_service_name" {
  type = string
}

variable "backend_uris" {
  type = list(string)
}

variable "resource_group_name" {
  type = string
}

data "azurerm_api_management" "apiManagementService" {
  name                = var.api_management_service_name
  resource_group_name = var.resource_group_name
}

resource "azapi_resource" "backend" {
  count = length(var.backend_uris)

  type      = "Microsoft.ApiManagement/service/backends@2023-09-01-preview"
  name      = "aoai-${count.index}"
  parent_id = data.azurerm_api_management.apiManagementService.id

  body = jsonencode({
    properties = {
      url      = var.backend_uris[count.index]
      protocol = "http"
      circuitBreaker = {
        rules = [
          {
            name = "breakerRule"
            failureCondition = {
              count    = 1
              interval = "PT1M"
              statusCodeRanges = [
                {
                  min = 429
                  max = 429
                }
              ]
              errorReasons = ["timeout"]
            }
            tripDuration     = "PT1M"
            acceptRetryAfter = true
          }
        ]
      }
    }
  })
  response_export_values = ["*"]
}


output "backend_names" {
  value = [for i in range(0, length(var.backend_uris)) : azapi_resource.backend[i].name]
}
