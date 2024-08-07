output "apiManagementServiceName" {
  description = "The name of the API Management service instance"
  value       = var.apiManagementServiceName
}

# To check
# output "apiManagementAzureOpenAIProductSubscriptionKey" {
#   value = azurerm_api_management_subscription.example.primary_key
#   description = "The primary key of the Azure OpenAI product subscription."
# }
