# param apiManagementServiceName string
# param backendUris array

# resource apiManagementService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
#   name: apiManagementServiceName
# }

# resource backend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = [for (backendUri, i) in backendUris: {
#   parent: apiManagementService
#   name: 'aoai-${i}'
#   properties: {
#     url: backendUri
#     protocol: 'http'
#     circuitBreaker: {
#       rules: [{
#         name: 'breakerRule'
#         failureCondition: {
#           count: 1
#           interval: 'PT1M'
#           statusCodeRanges: [ {
#             min: 429
#             max: 429
#           }]
#           errorReasons: ['timeout']
#         }
#         tripDuration: 'PT1M'
#         acceptRetryAfter: true
#       }]
#     }
#   }
# }
# ]

# output backendNames array = [for i in range(0, length(backendUris)): backend[i].name]

variable "api_management_service_name" {
  type = string
}

variable "backend_uris" {
  type = list(string)
}

resource "azurerm_api_management" "apiManagementService" {
  name                = var.api_management_service_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  publisher_name      = "example"
  publisher_email     = "example@example.com"
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_backend" "backend" {
  count               = length(var.backend_uris)
  name                = "aoai-${count.index}"
  api_management_name = azurerm_api_management.apiManagementService.name
  resource_group_name = azurerm_resource_group.example.name

  url      = var.backend_uris[count.index]
  protocol = "http"

  circuit_breaker {
    rules = [
      {
        name = "breakerRule"
        failure_condition {
          count              = 1
          interval           = "PT1M"
          status_code_ranges = [
            {
              min = 429
              max = 429
            }
          ]
          error_reasons = ["timeout"]
        }
        trip_duration     = "PT1M"
        accept_retry_after = true
      }
    ]
  }
}

output "backend_names" {
  value = [for i in range(0, length(var.backend_uris)): azurerm_api_management_backend.backend[i].name]
}
