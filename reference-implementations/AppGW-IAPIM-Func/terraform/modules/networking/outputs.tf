output "apim_cs_vnet_name" {
  value = local.apim_cs_vnet_name
}

output "apim_cs_vnet_id" {
  value = azurerm_virtual_network.apim_cs_vnet.id
}

output "bastion_subnet_name" {
  value = local.bastion_subnet_name
}

output "devops_subnet_name" {
  value = local.devops_subnet_name
}

output "jumpbox_subnet_name" {
  value = local.jumpbox_subnet_name
}

output "appgateway_subnet_name" {
  value = local.appgateway_subnet_name
}

output "private_endpoint_subnet_name" {
  value = local.private_endpoint_subnet_name
}

output "backend_subnet_name" {
  value = local.backend_subnet_name
}

output "apim_subnet_name" {
  value = local.apim_subnet_name
}

output "bastion_subnet_id" {
  value = "${azurerm_virtual_network.apim_cs_vnet.id}/subnets/${local.bastion_subnet_name}"
}

output "cicd_agent_subnet_id" {
  value = "${azurerm_virtual_network.apim_cs_vnet.id}/subnets/${local.devops_subnet_name}"
}

output "jumpbox_subnet_id" {
  value = "${azurerm_virtual_network.apim_cs_vnet.id}/subnets/${local.jumpbox_subnet_name}"
}

output "appgateway_subnet_id" {
  value = "${azurerm_virtual_network.apim_cs_vnet.id}/subnets/${local.appgateway_subnet_name}"
}

output "private_endpoint_subnet_id" {
  value = "${azurerm_virtual_network.apim_cs_vnet.id}/subnets/${local.private_endpoint_subnet_name}"
}

output "backend_subnet_id" {
  value = "${azurerm_virtual_network.apim_cs_vnet.id}/subnets/${local.backend_subnet_name}"
}

output "apim_subnet_id" {
  value = "${azurerm_virtual_network.apim_cs_vnet.id}/subnets/${local.apim_subnet_name}"
}

output "public_ip" {
  value = azurerm_public_ip.public_ip.id
}