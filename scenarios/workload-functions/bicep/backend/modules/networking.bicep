param resourceSuffix string

param location string

param vnetName string

param backEndAddressPrefix string = '10.2.6.0/24'

var backEndSubnetName = 'snet-bcke-${resourceSuffix}'
var backEndSNNSG = 'nsg-bcke-${resourceSuffix}'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
}

resource subnetBackend 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: backEndSubnetName
  parent: vnet
  properties: {
    addressPrefix: backEndAddressPrefix
    delegations: [
      {
        name: 'delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
      }
    ]
    privateEndpointNetworkPolicies: 'Enabled'
    networkSecurityGroup: {
      id: backEndNSG.id
    }
  }
}

resource backEndNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: backEndSNNSG
  location: location
  properties: {
    securityRules: [
    ]
  }
}

output backEndSubnetName string = backEndSubnetName 
output backEndSubnetid string = subnetBackend.id
