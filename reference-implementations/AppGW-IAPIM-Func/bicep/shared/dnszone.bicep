param vnetName string
param vnetRG string
param apimName string
param apimRG string

/*
 Retrieve APIM and Virtual Network
*/

resource apim 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimName
  scope: resourceGroup(apimRG)
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRG)
}

/*
Createa a Private DNS ZOne, A Record and Vnet Link for each of the below endpoints

API Gateway	                contosointernalvnet.azure-api.net
Developer portal	          contosointernalvnet.portal.azure-api.net
The new developer portal	  contosointernalvnet.developer.azure-api.net
Direct management endpoint	contosointernalvnet.management.azure-api.net
Git	                        contosointernalvnet.scm.azure-api.net
*/

// DNS Zones

resource gatewayDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}

  resource gatewayRecord 'A' = {
    name: apimName
    dependsOn: [
      apim
    ]
    properties: {
      aRecords: [
        {
          ipv4Address: apim.properties.privateIPAddresses[0]
        }
      ]
      ttl: 36000
    }
  }

  resource gatewayVnetLink 'virtualNetworkLinks' = {
    name: 'gateway-vnet-dns-link'
    location: 'global'
    properties: {
      registrationEnabled: true
      virtualNetwork: {
        id: vnet.id
      }
    }
  }
}

resource portalDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'portal.azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}

  resource portalRecord 'A' = {
    name: apimName
    dependsOn: [
      apim
    ]
    properties: {
      aRecords: [
        {
          ipv4Address: apim.properties.privateIPAddresses[0]
        }
      ]
      ttl: 36000
    }
  }

  resource portalVnetLink 'virtualNetworkLinks' = {
    name: 'gateway-vnet-dns-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnet.id
      }
    }
  }
}

resource developerDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'developer.azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}

  resource developerRecord 'A' = {
    name: apimName
    dependsOn: [
      apim
    ]
    properties: {
      aRecords: [
        {
          ipv4Address: apim.properties.privateIPAddresses[0]
        }
      ]
      ttl: 36000
    }
  }

  resource developerVnetLink 'virtualNetworkLinks' = {
    name: 'gateway-vnet-dns-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnet.id
      }
    }
  }
}

resource managementDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'management.azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}

  resource managementRecord 'A' = {
    name: apimName
    dependsOn: [
      apim
    ]
    properties: {
      aRecords: [
        {
          ipv4Address: apim.properties.privateIPAddresses[0]
        }
      ]
      ttl: 36000
    }
  }

  resource managementVnetLink 'virtualNetworkLinks' = {
    name: 'gateway-vnet-dns-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnet.id
      }
    }
  }
}

resource scmDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'scm.azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}

  resource scmRecord 'A' = {
    name: apimName
    dependsOn: [
      apim
    ]
    properties: {
      aRecords: [
        {
          ipv4Address: apim.properties.privateIPAddresses[0]
        }
      ]
      ttl: 36000
    }
  }

  resource scmVnetLink 'virtualNetworkLinks' = {
    name: 'gateway-vnet-dns-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnet.id
      }
    }
  }
}
