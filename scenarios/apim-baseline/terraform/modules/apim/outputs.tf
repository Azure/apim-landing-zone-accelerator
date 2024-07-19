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