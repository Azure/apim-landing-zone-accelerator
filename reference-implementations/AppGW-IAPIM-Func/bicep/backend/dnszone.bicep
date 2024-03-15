param vnetName string
param vnetRG string
param privateEndpointName string
param groupId string
param storageName string
param standardDomain string = 'windows.net'
param domain string = 'privatelink.${groupId}.core.${standardDomain}'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRG)
}

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: domain
  location: 'global'

  resource vnetLinks 'virtualNetworkLinks' = {
    name: uniqueString(vnet.id)
    location: 'global'
    properties: {
      virtualNetwork: {
        id: vnet.id
      }
      registrationEnabled: false
    }
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: '${privateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${storageName}-${groupId}-core-windows-net'
        properties: {
          privateDnsZoneId: dnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    dnsZone::vnetLinks
  ]
}

output dnsZoneId string = dnsZone.id
output vnetLinksLink string = dnsZone::vnetLinks.id
output dnsZoneGroupId string = dnsZoneGroup.id
