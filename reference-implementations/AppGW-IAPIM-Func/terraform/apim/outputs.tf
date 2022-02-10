output "apim_id" {
    description = "The resource id of the apim instance"
    value = azurerm_api_management.apim_internal.id
}

output "apim_rg" {
    description = "The resource group of the apim instance"
    value = azurerm_api_management.apim_internal.resource_group_name
}