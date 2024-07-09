output "apiManagementServiceName" {
  description = "The name of the API Management service instance"
  value       = var.apiManagementServiceName
}

output "apiManagementAzureOpenAIProductSubscriptionKey" {
  description = "The primary key of the Azure Open AI Product Subscription"
  # The value will depend on how you're creating the Azure Open AI Product Subscription in your Terraform code.
}
