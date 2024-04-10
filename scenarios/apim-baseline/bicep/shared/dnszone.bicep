
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
The new developer portal	  contosointernalvnet.developer.azure-api.net
*/

// DNS Zones

resource apimDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'azure-api.net'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {}
}

// A Records

resource gatewayRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: apimDnsZone
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

resource developerRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: apimDnsZone
  name: '${apimName}.developer'
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

// Vnet Links

resource gatewayVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: apimDnsZone
  name: 'gateway-vnet-dns-link'
  location: 'global'
  dependsOn: [
    vnet
  ]
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: vnet.id
    }
  }
}
