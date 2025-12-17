output "gw_pip_id" {
  value = azurerm_public_ip.public_ip.id
}

output "gw_pip_fqdn" {
  value = azurerm_public_ip.public_ip.fqdn
}

output "app_gateway_name" {
  value = azurerm_application_gateway.network.name
}