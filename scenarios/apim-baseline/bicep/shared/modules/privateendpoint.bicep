param privateEndpointName string
param groupId string
param location string
param vnetName string
param networkingResourceGroupName string
param subnetId string
param serviceResourceId string
param createDnsZone bool = true
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

module dnsZoneNew './dnszone.bicep' = if (createDnsZone == true) {
  name: take('${replace(domain, '.', '-')}-deploy', 64)
  params: {
    vnetName: vnetName
    networkingResourceGroupName: networkingResourceGroupName
    domain: domain
  }
  dependsOn: [
    privateEndpoint
  ]
}

resource dnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' existing = if (createDnsZone == false) {
  name: domain 
}

var dnsZoneName = (createDnsZone == true) ? dnsZoneNew.outputs.dnsZoneName : dnsZone.name
var dnsZoneId = (createDnsZone == true) ? dnsZoneNew.outputs.dnsZoneId : dnsZone.id

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: 'default'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {      
        name: dnsZoneName
        properties: {
          privateDnsZoneId: dnsZoneId          
        }
      }
    ]
  }
}

output privateEndpointId string = privateEndpoint.id
output dnsZoneGroupId string = dnsZoneGroup.id
