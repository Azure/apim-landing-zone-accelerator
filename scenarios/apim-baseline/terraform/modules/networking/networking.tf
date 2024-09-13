locals {
  apim_cs_vnet_name            = "vnet-apim-cs-${var.resourceSuffix}"
  appgateway_subnet_name       = "snet-apgw-${var.resourceSuffix}"
  deploy_subnet_name           = "snet-deploy-${var.resourceSuffix}"
  appgateway_snnsg             = "nsg-apgw-${var.resourceSuffix}"
  private_endpoint_subnet_name = "snet-prep-${var.resourceSuffix}"
  private_endpoint_snnsg       = "nsg-prep-${var.resourceSuffix}"
  apim_subnet_name             = "snet-apim-${var.resourceSuffix}"
  owner                        = "APIM Const Set"
  appgateway_public_ipname     = "pip-appgw-${var.resourceSuffix}"
  apim_snnsg                   = "nsg-apim-${var.resourceSuffix}"
}

resource "azurerm_network_security_group" "appgateway_nsg" {
  name                = local.appgateway_snnsg
  location            = var.location
  resource_group_name = var.resourceGroupName

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
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_network_security_group" "apim_snnsg_nsg" {
  name                = local.apim_snnsg
  location            = var.location
  resource_group_name = var.resourceGroupName

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

  security_rule {
    name                       = "apim-azure-monitor"
    priority                   = 2030
    protocol                   = "Tcp"
    destination_port_range     = "443"
    access                     = "Allow"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureMonitor"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_network_security_group" "private_endpoint_snnsg_nsg" {
  name                = local.private_endpoint_snnsg
  location            = var.location
  resource_group_name = var.resourceGroupName

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_virtual_network" "apim_cs_vnet" {
  name                = local.apim_cs_vnet_name
  location            = var.location
  resource_group_name = var.resourceGroupName
  address_space       = [var.apimCSVNetNameAddressPrefix]

  tags = {
    Owner = local.owner
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet" "appgateway_subnet" {
  name                 = local.appgateway_subnet_name
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.apim_cs_vnet.name
  address_prefixes     = [var.appGatewayAddressPrefix]

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet_network_security_group_association" "appgateway_subnet" {
  subnet_id                 = azurerm_subnet.appgateway_subnet.id
  network_security_group_id = azurerm_network_security_group.appgateway_nsg.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = local.private_endpoint_subnet_name
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.apim_cs_vnet.name
  address_prefixes     = [var.privateEndpointAddressPrefix]

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet_network_security_group_association" "private_endpoint_subnet" {
  subnet_id                 = azurerm_subnet.private_endpoint_subnet.id
  network_security_group_id = azurerm_network_security_group.private_endpoint_snnsg_nsg.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet" "deploy_subnet" {
  name                 = local.deploy_subnet_name
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.apim_cs_vnet.name
  address_prefixes     = [var.deploymentAddressPrefix]

  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "Microsoft.ContainerInstance.containerGroups"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet" "apim_subnet" {
  name                 = local.apim_subnet_name
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.apim_cs_vnet.name
  address_prefixes     = [var.apimAddressPrefix]

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet_network_security_group_association" "apim_subnet" {
  subnet_id                 = azurerm_subnet.apim_subnet.id
  network_security_group_id = azurerm_network_security_group.apim_snnsg_nsg.id

  lifecycle {
    prevent_destroy = true
  }
}
