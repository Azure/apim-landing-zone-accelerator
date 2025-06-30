/* Creates a Private DNS ZOne, A Records and Vnet Link for each of the below endpoints
API Gateway	                contosointernalvnet.azure-api.net
Developer portal	        contosointernalvnet.portal.azure-api.net
The new developer portal	contosointernalvnet.developer.azure-api.net
Direct management endpoint	contosointernalvnet.management.azure-api.net
Git	                        contosointernalvnet.scm.azure-api.net */

#-------------------------------
# DNS zones 
#-------------------------------
resource "azurerm_private_dns_zone" "gateway" {
  name                = "regional.azure-api.net"
  resource_group_name = var.resourceGroupName

  lifecycle {
    #prevent_destroy = true
  }
}


#-------------------------------
# A records for the DNS zones
#-------------------------------
resource "azurerm_private_dns_a_record" "gateway_record" {
  name                = lower(var.apimRegionalName)
  zone_name           = azurerm_private_dns_zone.gateway.name
  resource_group_name = var.resourceGroupName
  ttl                 = 36000
  records             = [var.apimPrivateIp]

  lifecycle {
    #prevent_destroy = true
  }
}

resource "azurerm_private_dns_a_record" "gateway_second_record" {
  name                = lower(var.apimSecondRegionalName)
  zone_name           = azurerm_private_dns_zone.gateway.name
  resource_group_name = var.resourceGroupName
  ttl                 = 36000
  records             = [var.apimSecondPrivateIp]

  lifecycle {
    #prevent_destroy = true
  }
}

#-------------------------------
# Vnet links
#-------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "gateway_vnetlink" {
  name                  = "gateway-vnet-link"
  resource_group_name   = var.resourceGroupName
  private_dns_zone_name = azurerm_private_dns_zone.gateway.name
  virtual_network_id    = var.apimVnetId

  lifecycle {
    #prevent_destroy = true
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "gateway_second_vnetlink" {
  name                  = "gateway-second-vnet-link"
  resource_group_name   = var.resourceGroupName
  private_dns_zone_name = azurerm_private_dns_zone.gateway.name
  virtual_network_id    = var.apimSecondVnetId

  lifecycle {
    #prevent_destroy = true
  }
}

