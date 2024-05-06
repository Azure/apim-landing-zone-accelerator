param resourceSuffix string

param location string

param vnetName string

param privateEndpointAddressPrefix string = '10.2.5.0/24'
param backEndAddressPrefix string = '10.2.6.0/24'

var privateEndpointSubnetName = 'snet-prep-${resourceSuffix}'
var backEndSubnetName = 'snet-bcke-${resourceSuffix}'
var privateEndpointSNNSG = 'nsg-prep-${resourceSuffix}'
var backEndSNNSG = 'nsg-bcke-${resourceSuffix}'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
}

resource subnetPE 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: privateEndpointSubnetName
  parent: vnet
  properties: {
    addressPrefix: privateEndpointAddressPrefix
    networkSecurityGroup: {
      id: privateEndpointNSG.id
    }
    privateEndpointNetworkPolicies: 'Disabled'
  }
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

resource privateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: privateEndpointSNNSG
  location: location
  properties: {
    securityRules: [
    ]
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
output privateEndpointSubnetName string = privateEndpointSubnetName  
output privateEndpointSubnetid string = subnetPE.id 
output backEndSubnetid string = subnetBackend.id
