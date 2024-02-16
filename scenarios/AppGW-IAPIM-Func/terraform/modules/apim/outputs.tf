output "apim_id" {
  description = "The resource id of the apim instance"
  value       = azurerm_api_management.apim_internal.id
}

output "apim_name" {
  description = "The resource name of the apim instance"
  value       = azurerm_api_management.apim_internal.name
}

output "apim_resource_group_name" {
  description = "The resource group name of the apim instance"
  value       = azurerm_resource_group.apim_internal_rg.name
}

output "apim_resource_group_location" {
  description = "The resource group location of the apim instance"
  value       = azurerm_resource_group.apim_internal_rg.location
}

output "name" {
  description = "The name of the apim instance"
  value       = azurerm_api_management.apim_internal.name
}

output "private_ip_addresses" {
  description = "Used to connect from within the network to API Management endpoints"
  value       = azurerm_api_management.apim_internal.private_ip_addresses
}