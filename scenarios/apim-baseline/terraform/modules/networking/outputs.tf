output "apimSubnetId" {
  value = azurerm_subnet.apim_subnet.id
}

output "appGatewaySubnetId" {
  value = azurerm_subnet.appgateway_subnet.id
}

output "apimVnetId" {
  value = azurerm_virtual_network.apim_cs_vnet.id
}

output "deploymentSubnetId" {
  value = azurerm_subnet.deploy_subnet.id
}
