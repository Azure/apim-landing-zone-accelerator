output "id" {
  value = azurerm_cognitive_account.openai.id
  description = "Specifies the resource id of the log analytics workspace"
}

output "location" {
  value = azurerm_cognitive_account.openai.location
  description = "Specifies the location of the log analytics workspace"
}

output "name" {
  value = azurerm_cognitive_account.openai.name
  description = "Specifies the name of the log analytics workspace"
}

output "resource_group_name" {
  value = azurerm_cognitive_account.openai.resource_group_name
  description = "Specifies the name of the resource group that contains the log analytics workspace"
}

output "endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
  description = "Specifies the endpoint of the Azure OpenAI Service."
}

# This is in bicep - but we are using AZ CLI in the deployment script
# to get the key instead of exposing it in the output
# output "primary_access_key" {
#   value = azurerm_cognitive_account.openai.primary_access_key
#   sensitive = true
#   description = "Specifies the primary access key of the Azure OpenAI Service."
# }

# This is in bicep - but we are using AZ CLI in the deployment script
# to get the key instead of exposing it in the output
# output "secondary_access_key" {
#   value = azurerm_cognitive_account.openai.secondary_access_key
#   sensitive = true
#   description = "Specifies the secondary access key of the Azure OpenAI Service."
# }
