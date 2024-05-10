param privateEndpointName string
param groupId string
param location string
param vnetName string
param networkingResourceGroupName string
param subnetId string
param serviceResourceId string
param privateDnsZoneName string
param domain string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: serviceResourceId
          groupIds: [
            groupId
          ]
        }
      }
    ]
  }
}

module dnsZone './dnszone.bicep' = {
  name: privateDnsZoneName
  params: {
    vnetName: vnetName
    networkingResourceGroupName: networkingResourceGroupName
    domain: domain
  }
  dependsOn: [
    privateEndpoint
  ]
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: 'default'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {      
        name: dnsZone.outputs.dnsZoneName
        properties: {
          privateDnsZoneId: dnsZone.outputs.dnsZoneId          
        }
      }
    ]
  }
}

output privateEndpointId string = privateEndpoint.id
output dnsZoneId string = dnsZone.outputs.dnsZoneId
output dnsZoneGroupId string = dnsZoneGroup.id
output vnetLinksId string = dnsZone.outputs.vnetLinksLink
