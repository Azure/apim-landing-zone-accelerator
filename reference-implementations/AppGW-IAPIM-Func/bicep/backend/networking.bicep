param privateEndpointName string
param groupId string
param location string
param vnetName string
param vnetRG string
param subnetId string
param storageAccountId string
param privateDnsZoneName string
param storageAcountName string

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
          privateLinkServiceId: storageAccountId
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
    vnetRG: vnetRG
    groupId: groupId
    privateEndpointName: privateEndpointName
    storageName: storageAcountName 
  }
  dependsOn: [
    privateEndpoint
  ]
}

output privateEndpointId string = privateEndpoint.id
output dnsZoneId string = dnsZone.outputs.dnsZoneId
output dnsZoneGroupId string = dnsZone.outputs.dnsZoneGroupId
output vnetLinksId string = dnsZone.outputs.vnetLinksLink
