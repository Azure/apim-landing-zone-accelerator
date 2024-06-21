
param vnetName                  string
param networkingResourceGroupName string
param apimName                  string
param apimRG                    string


resource apim 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimName
  scope: resourceGroup(apimRG)
}

module dnsZone '../../shared/modules/dnszone.bicep' = {
  name: 'apimDnsZoneDeploy'
  params: {
    vnetName: vnetName
    networkingResourceGroupName: networkingResourceGroupName
    domain: '${apimName}.azure-api.net'
  }
}

resource apimDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: '${apimName}.azure-api.net'
}


resource gatewayRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: apimDnsZone
  name: '@'
  dependsOn: [
    apim
    dnsZone
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
  name: 'developer'
  dependsOn: [
    apim
    dnsZone
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
