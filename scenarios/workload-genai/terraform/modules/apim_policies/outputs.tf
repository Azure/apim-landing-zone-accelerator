output "apiManagementServiceName" {
  description = "The name of the API Management service instance"
  value       = var.apiManagementServiceName
}

# This is in bicep - but we are using AZ CLI in the deployment script
# to get the key instead of exposing it in the output
# output "apiManagementAzureOpenAIProductSubscriptionKey" {
#   value = azurerm_api_management_subscription.example.primary_key
#   description = "The primary key of the Azure OpenAI product subscription."
# }
