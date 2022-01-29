locals {
  owner = "APIM Const Set"
  apim_cs_vnet_name                 = "vnet-apim-cs-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  bastion_subnet_name               = "AzureBastionSubnet"
  devops_subnet_name                = "snet-devops-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  jumpbox_subnet_name                = "snet-jbox-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}-001"
  appgateway_subnet_name            = "snet-apgw-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}-001"
  private_endpoint_subnet_name      = "snet-prep-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}-001"
  backend_subnet_name                = "snet-bcke-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}-001"
  apim_subnet_name                  = "snet-apim-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}-001"
  bastion_name                      = "bastion-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  bastion_ip_configName             = "bastionipcfg-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  bastion_snnsg                     = "nsg-bast-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  devops_snnsg                      = "nsg-devops-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  jumpbox_snnsg                     = "nsg-jbox-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  appgateway_snnsg                  = "nsg-apgw-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  private_endpoint_snnsg            = "nsg-prep-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  backend_snnsg                     = "nsg-bcke-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  apim_snnsg                        = "nsg-apim-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  public_ip_address_name            = "pip-apimcs-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
  public_ip_address_name_bastion    = "pip-bastion-${var.workload_name}-${var.deployment_environment}-${var.resource_group_location}"
}

//Vnet
resource "azurerm_virtual_network" "apim_cs_vnet" {
  name                = local.apim_cs_vnet_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  address_space       = [var.apim_cs_vnet_name_address_prefix]
  //enableVmProtection: false
  //ddos_protection_plan false
  
  subnet {
    name           = local.bastion_subnet_name
    address_prefix = var.bastion_address_prefix
    security_group = azurerm_network_security_group.bastion_nsg.id
  }

  subnet {
    name           = local.devops_subnet_name
    address_prefix = var.devops_name_address_prefix
    security_group = azurerm_network_security_group.devops_nsg.id
  }

  subnet {
    name           = local.jumpbox_subnet_name
    address_prefix = var.jumpbox_address_prefix
    security_group = azurerm_network_security_group.jumpbox_nsg.id
  }

  subnet {
    name           = local.appgateway_subnet_name
    address_prefix = var.appgateway_address_prefix
    security_group = azurerm_network_security_group.appgateway_nsg.id
  }

  subnet {
    name           = local.private_endpoint_subnet_name
    address_prefix = var.private_endpoint_address_prefix
    security_group = azurerm_network_security_group.private_endpoint_snnsg_nsg.id
  }

  subnet {
    name           = local.backend_subnet_name
    address_prefix = var.backend_address_prefix
    security_group = azurerm_network_security_group.backend_snnsg_nsg.id
  }

   subnet {
    name           = local.apim_subnet_name
    address_prefix = var.apim_address_prefix
    security_group = azurerm_network_security_group.apim_snnsg_nsg.id
  }

  tags = {
    Owner = local.owner
  }
}

//Bastion NSG
resource "azurerm_network_security_group" "bastion_nsg" {
  name                = local.bastion_subnet_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                          = "AllowHttpsInbound"
    priority                      = 120
    protocol                      = "Tcp"
    destination_port_range        = "443"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "Internet"
    destination_address_prefix    = "*"
  }

  security_rule {
    name                          = "AllowGatewayManagerInbound"
    priority                      = 130
    protocol                      = "Tcp"
    destination_port_range        = "443"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "GatewayManager"
    destination_address_prefix    = "*"
  }

  security_rule {
    name                          = "AllowAzureLoadBalancerInbound"
    priority                      = 140
    protocol                      = "Tcp"
    destination_port_range        = "443"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "AzureLoadBalancer"
    destination_address_prefix    = "*"
  }

  security_rule {
    name                          = "AllowBastionHostCommunicationInbound"
    priority                      = 150
    protocol                      = "*"
    destination_port_ranges       = ["8080", "5701"]
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "VirtualNetwork"
    destination_address_prefix    = "VirtualNetwork"
  }

  security_rule {
    name                          = "DenyAllInbound"
    priority                      = 4096
    protocol                      = "*"
    destination_port_range        = "*"
    access                        = "Deny"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }

  security_rule {
    name                          = "AllowSshRdpOutbound"
    priority                      = 100
    protocol                      = "*"
    destination_port_ranges       = ["22", "3389"]
    access                        = "Allow"
    direction                     = "Outbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "VirtualNetwork"
  }

  security_rule {
    name                          = "AllowAzureCloudOutbound"
    priority                      = 110
    protocol                      = "Tcp"
    destination_port_range        = "443"
    access                        = "Allow"
    direction                     = "Outbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "AzureCloud"
  }

  security_rule {
    name                          = "AllowBastionCommunication"
    priority                      = 120
    protocol                      = "*"
    destination_port_ranges       = ["8080", "5701"]
    access                        = "Allow"
    direction                     = "Outbound"
    source_port_range             = "*"
    source_address_prefix         = "VirtualNetwork"
    destination_address_prefix    = "VirtualNetwork"
  }

  security_rule {
    name                          = "AllowGetSessionInformation"
    priority                      = 130
    protocol                      = "*"
    destination_port_range        = "80"
    access                        = "Allow"
    direction                     = "Outbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "Internet"
  }
}

//DevOps NSG
resource "azurerm_network_security_group" "jumpbox_nsg" {
  name                = local.jumpbox_subnet_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                          = "AllowRdpInbound"
    priority                      = 1000
    protocol                      = "Tcp"
    destination_port_range        = "3389"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }
}

//Jumpbox NSG
resource "azurerm_network_security_group" "devops_nsg" {
  name                = local.devops_subnet_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                          = "AllowRdpInbound"
    priority                      = 1000
    protocol                      = "Tcp"
    destination_port_range        = "3389"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }
}

//App Gateway NSG
resource "azurerm_network_security_group" "appgateway_nsg" {
  name                = local.appgateway_subnet_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                          = "AllowRdpInbound"
    priority                      = 1000
    protocol                      = "Tcp"
    destination_port_range        = "3389"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }

  security_rule {
    name                          = "AllowHealthProbesInbound"
    priority                      = 100
    protocol                      = "*"
    destination_port_range        = "65200-65535"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "GatewayManager"
    destination_address_prefix    = "*"
  }

  security_rule {
    name                          = "AllowTLSInbound"
    priority                      = 110
    protocol                      = "Tcp"
    destination_port_range        = "443"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }

  security_rule {
    name                          = "AllowHTTPInbound"
    priority                      = 111
    protocol                      = "Tcp"
    destination_port_range        = "80"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }

  security_rule {
    name                          = "AllowAzureLoadBalancerInbound"
    priority                      = 121
    protocol                      = "Tcp"
    destination_port_range        = "*"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "AzureLoadBalancer"
    destination_address_prefix    = "*"
  }

  security_rule {
    name                          = "DenyAll"
    priority                      = 130
    protocol                      = "*"
    destination_port_range        = "*"
    access                        = "Deny"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }
}

//Private Endpoint SNNSG NSG
resource "azurerm_network_security_group" "private_endpoint_snnsg_nsg" {
  name                = local.private_endpoint_snnsg
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                          = "AllowRdpInbound"
    priority                      = 1000
    protocol                      = "Tcp"
    destination_port_range        = "3389"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }
}

//Backend SNNSG NSG
resource "azurerm_network_security_group" "backend_snnsg_nsg" {
  name                = local.backend_snnsg
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                          = "AllowRdpInbound"
    priority                      = 1000
    protocol                      = "Tcp"
    destination_port_range        = "3389"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }
}

//APIM SNNSG NSG
resource "azurerm_network_security_group" "apim_snnsg_nsg" {
  name                = local.apim_snnsg
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                          = "AllowApimVnetInbound"
    priority                      = 2000
    protocol                      = "Tcp"
    destination_port_range        = "3443"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "ApiManagement"
    destination_address_prefix    = "VirtualNetwork"
  }

  security_rule {
    name                          = "AllowRdpInbound"
    priority                      = 1000
    protocol                      = "Tcp"
    destination_port_range        = "3389"
    access                        = "Allow"
    direction                     = "Inbound"
    source_port_range             = "*"
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }
}

//Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = local.public_ip_address_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Dynamic"
}

//Bastion public IP
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = local.public_ip_address_name_bastion
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard"
  sku_tier            = "Regional"
  allocation_method   = "Static"
  ip_version          = "IPv4"
}

//Bastion host
resource "azurerm_bastion_host" "bastion_host" {
  name                = local.bastion_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    //privateIPAllocationMethod: 'Dynamic'
    name                 = local.bastion_ip_configName    
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
    subnet_id            = "${azurerm_virtual_network.apim_cs_vnet.id}/subnets/${local.bastion_subnet_name}"
  }

  tags = {
    Owner = local.owner
  }
}