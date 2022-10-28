locals {
  resource_suffix                = "${var.workload_name}-${var.deployment_environment}-${var.location}"
  resource_suffix_id             = "001"
  resource_group_name            = "rg-networking-${local.resource_suffix}"
  owner                          = "APIM Const Set"
  apim_cs_vnet_name              = "vnet-apim-cs-${local.resource_suffix}"
  bastion_subnet_name            = "AzureBastionSubnet"
  devops_subnet_name             = "snet-devops-${local.resource_suffix}"
  jumpbox_subnet_name            = "snet-jbox-${local.resource_suffix}-${local.resource_suffix_id}"
  appgateway_subnet_name         = "snet-apgw-${local.resource_suffix}-${local.resource_suffix_id}"
  private_endpoint_subnet_name   = "snet-prep-${local.resource_suffix}-${local.resource_suffix_id}"
  backend_subnet_name            = "snet-bcke-${local.resource_suffix}-${local.resource_suffix_id}"
  apim_subnet_name               = "snet-apim-${local.resource_suffix}-${local.resource_suffix_id}"
  bastion_name                   = "bastion-${local.resource_suffix}"
  bastion_ip_configName          = "bastionipcfg-${local.resource_suffix}"
  bastion_snnsg                  = "nsg-bast-${local.resource_suffix}"
  devops_snnsg                   = "nsg-devops-${local.resource_suffix}"
  jumpbox_snnsg                  = "nsg-jbox-${local.resource_suffix}"
  appgateway_snnsg               = "nsg-apgw-${local.resource_suffix}"
  private_endpoint_snnsg         = "nsg-prep-${local.resource_suffix}"
  backend_snnsg                  = "nsg-bcke-${local.resource_suffix}"
  apim_snnsg                     = "nsg-apim-${local.resource_suffix}"
  public_ip_address_name         = "pip-apimcs-${local.resource_suffix}"
  public_ip_address_name_bastion = "pip-bastion-${local.resource_suffix}"
}

resource "azurerm_resource_group" "networking_resourece_group" {
  name     = local.resource_group_name
  location = var.location
}

//Vnet
resource "azurerm_virtual_network" "apim_cs_vnet" {
  name                = local.apim_cs_vnet_name
  location            = azurerm_resource_group.networking_resourece_group.location
  resource_group_name = azurerm_resource_group.networking_resourece_group.name
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
  name                = local.bastion_snnsg
  location            = azurerm_resource_group.networking_resourece_group.location
  resource_group_name = azurerm_resource_group.networking_resourece_group.name

  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 120
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowGatewayManagerInbound"
    priority                   = 130
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 140
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowBastionHostCommunicationInbound"
    priority                   = 150
    protocol                   = "*"
    destination_port_ranges    = ["8080", "5701"]
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowSshRdpOutbound"
    priority                   = 100
    protocol                   = "*"
    destination_port_ranges    = ["22", "3389"]
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureCloudOutbound"
    priority                   = 110
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name                       = "AllowBastionCommunication"
    priority                   = 120
    protocol                   = "*"
    destination_port_ranges    = ["8080", "5701"]
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowGetSessionInformation"
    priority                   = 130
    protocol                   = "*"
    destination_port_range     = "80"
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

//JumpBox NSG
resource "azurerm_network_security_group" "jumpbox_nsg" {
  name                = local.jumpbox_snnsg
  location            = azurerm_resource_group.networking_resourece_group.location
  resource_group_name = azurerm_resource_group.networking_resourece_group.name
}

//DevOps NSG
resource "azurerm_network_security_group" "devops_nsg" {
  name                = local.devops_snnsg
  location            = azurerm_resource_group.networking_resourece_group.location
  resource_group_name = azurerm_resource_group.networking_resourece_group.name
}

//App Gateway NSG
resource "azurerm_network_security_group" "appgateway_nsg" {
  name                = local.appgateway_snnsg
  location            = azurerm_resource_group.networking_resourece_group.location
  resource_group_name = azurerm_resource_group.networking_resourece_group.name

  security_rule {
    name                       = "AllowHealthProbesInbound"
    priority                   = 100
    protocol                   = "*"
    destination_port_range     = "65200-65535"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowTLSInbound"
    priority                   = 110
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 111
    protocol                   = "Tcp"
    destination_port_range     = "80"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 121
    protocol                   = "Tcp"
    destination_port_range     = "*"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}

//Private Endpoint SNNSG NSG
resource "azurerm_network_security_group" "private_endpoint_snnsg_nsg" {
  name                = local.private_endpoint_snnsg
  location            = azurerm_resource_group.networking_resourece_group.location
  resource_group_name = azurerm_resource_group.networking_resourece_group.name
}

//Backend SNNSG NSG
resource "azurerm_network_security_group" "backend_snnsg_nsg" {
  name                = local.backend_snnsg
  location            = azurerm_resource_group.networking_resourece_group.location
  resource_group_name = azurerm_resource_group.networking_resourece_group.name
}

//APIM SNNSG NSG
resource "azurerm_network_security_group" "apim_snnsg_nsg" {
  name                = local.apim_snnsg
  location            = azurerm_resource_group.networking_resourece_group.location
  resource_group_name = azurerm_resource_group.networking_resourece_group.name

  security_rule {
    name                       = "AllowApimVnetInbound"
    priority                   = 2000
    protocol                   = "Tcp"
    destination_port_range     = "3443"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "apim-azure-infra-lb"
    priority                   = 2010
    protocol                   = "Tcp"
    destination_port_range     = "6390"
    access                     = "Allow"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "apim-azure-storage"
    priority                   = 2000
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Storage"
  }

  security_rule {
    name                       = "apim-azure-sql"
    priority                   = 2010
    protocol                   = "Tcp"
    destination_port_range     = "1443"
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "SQL"
  }

  security_rule {
    name                       = "apim-azure-kv"
    priority                   = 2020
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureKeyVault"
  }
}

//Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = local.public_ip_address_name
  resource_group_name = azurerm_resource_group.networking_resourece_group.name
  location            = azurerm_resource_group.networking_resourece_group.location
  allocation_method   = "Dynamic"
}

//Bastion public IP
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = local.public_ip_address_name_bastion
  resource_group_name = azurerm_resource_group.networking_resourece_group.name
  location            = azurerm_resource_group.networking_resourece_group.location
  sku                 = "Standard"
  sku_tier            = "Regional"
  allocation_method   = "Static"
  ip_version          = "IPv4"
}

//Bastion host
resource "azurerm_bastion_host" "bastion_host" {
  name                = local.bastion_name
  location            = azurerm_resource_group.networking_resourece_group.location
  resource_group_name = azurerm_resource_group.networking_resourece_group.name

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