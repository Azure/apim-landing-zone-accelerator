output "id" {
  value       = azurerm_application_gateway.network.id
  description = "Resource ID for the provisioned Application Gateway."
}

output "pip_id" {
  value       = azurerm_public_ip.public_ip.id
  description = "Resource ID for the Application Gateway associated Public IP."
}

output "pip_address" {
  value       = azurerm_public_ip.public_ip.ip_address
  description = "Resource ID for the Application Gateway associated Public IP."
}