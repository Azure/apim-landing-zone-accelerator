output "primaryBackendendFqdn" {
  value = azurerm_api_management.apim_internal.gateway_url
}

output "bakendUrl" {
  value = "${azurerm_api_management.apim_internal.name}.azure-api.net"
}

output "subscriptionKey" {
  value = random_uuid.starter_key.result
}

output "apimPrivateIp" {
  value = azurerm_api_management.apim_internal.private_ip_addresses[0]
}

output "apimName" {
  value = azurerm_api_management.apim_internal.name
}

output "apimIdentityName" {
  value = azurerm_user_assigned_identity.apimIdentity.name
}

output "apim_regional_url_1" {
  value = replace(azurerm_api_management.apim_internal.gateway_regional_url,"https://","")
}

output "apim_regional_url_2" {
  value = replace(azurerm_api_management.apim_internal.additional_location[0].gateway_regional_url,"https://","")
}

output "apim_regional_IP_1" {
  value = azurerm_api_management.apim_internal.private_ip_addresses[0]
}

output "apim_regional_IP_2" {
  value = azurerm_api_management.apim_internal.additional_location[0].private_ip_addresses[0]
}

output "apim_regional_name_1" {
  value = split(".",replace(azurerm_api_management.apim_internal.gateway_regional_url,"https://",""))[0]
}

output "apim_regional_name_2" {
  value = split(".",replace(azurerm_api_management.apim_internal.additional_location[0].gateway_regional_url,"https://",""))[0]
}

