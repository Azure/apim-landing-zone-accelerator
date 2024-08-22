# param apiManagementServiceName string
# param backends array

# resource apiManagementService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
#   name: apiManagementServiceName
# }

# resource backend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
#   parent: apiManagementService
#   name: 'aoai-lb-pool'
#   properties: {
#     title: 'aoai-lb-pool'
#     type: 'Pool'
#     pool: {
#       services: [for (backend, i) in backends: {
#         id: '/backends/${backend}'
#         priority: i%2 == 0 ? 1 : 2
#         weight: i+1
#       }]
#     }
#   }
# }

variable "api_management_service_name" {
  type = string
}

variable "backends" {
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
  name                = "aoai-lb-pool"
  api_management_name = azurerm_api_management.apiManagementService.name
  resource_group_name = azurerm_resource_group.example.name

  title = "aoai-lb-pool"
  type  = "http"

  pool {
    services = [
      for i, backend in var.backends : {
        id       = "/backends/${backend}"
        priority = i % 2 == 0 ? 1 : 2
        weight   = i + 1
      }
    ]
  }
}
