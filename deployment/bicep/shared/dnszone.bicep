
param vnetName                  string
param vnetRG                    string
param apimName                  string
param apimRG                    string

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
}

resource portalDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'portal.azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}
}

resource developerDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'developer.azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}
}

resource managementDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'management.azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}
}

resource scmDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'scm.azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}
}

// A Records

resource gatewayRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'azure-api.net/${apimName}'
  dependsOn: [
    apim
    gatewayDnsZone
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

resource portalRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'portal.azure-api.net/${apimName}'
  dependsOn: [
    apim
    portalDnsZone
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

resource developerRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'developer.azure-api.net/${apimName}'
  dependsOn: [
    apim
    developerDnsZone
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

resource managementRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'management.azure-api.net/${apimName}'
  dependsOn: [
    apim
    managementDnsZone
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

resource scmRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'scm.azure-api.net/${apimName}'
  dependsOn: [
    apim
    scmDnsZone
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

// Vnet Links

resource gatewayVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'azure-api.net/gateway-vnet-dns-link'
  location: 'global'
  dependsOn: [
    gatewayDnsZone
  ]
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource portalVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'portal.azure-api.net/gateway-vnet-dns-link'
  location: 'global'
  dependsOn: [
    portalDnsZone
  ]
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource developerVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'developer.azure-api.net/gateway-vnet-dns-link'
  location: 'global'
  dependsOn: [
    developerDnsZone
  ]
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource managementVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'management.azure-api.net/gateway-vnet-dns-link'
  location: 'global'
  dependsOn: [
    managementDnsZone
  ]
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource scmVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'scm.azure-api.net/gateway-vnet-dns-link'
  location: 'global'
  dependsOn: [
    scmDnsZone
  ]
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}
