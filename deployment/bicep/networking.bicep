// Parameters
@description('A short name for the workload being deployed')
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

param apimCSVNetNameAddressPrefix string = '10.2.0.0/16'

param bastionAddressPrefix string = '10.2.1.0/24'
param devOpsNameAddressPrefix string = '10.2.2.0/24'
param jumpBoxAddressPrefix string = '10.2.3.0/24'
param appGatewayAddressPrefix string = '10.2.4.0/24'
param privateEndpointAddressPrefix string = '10.2.5.0/24'
param backEndAddressPrefix string = '10.2.6.0/24'
param apimAddressPrefix string = '10.2.7.0/24'

@description('A short name for the PL that will created between Funcs')
param privateLinkName string = 'myPL'

@description('Func id for PL to create')
param functionId string = '123131'


// Variables
var owner = 'APIM Const Set'
var location = resourceGroup().location


var apimCSVNetName = 'vnet-apim-cs-${workloadName}-${environment}-${location}'

var bastionSubnetName = 'snet-bast-${workloadName}-${environment}-${location}'
var devOpsSubnetName = 'snet-devops-${workloadName}-${environment}-${location}'
var jumpBoxSubnetName = 'snet-jbox-${workloadName}-${environment}-${location}-001'
var appGatewaySubnetName = 'snet-apgw-${workloadName}-${environment}-${location}-001'
var privateEndpointSubnetName = 'snet-prep-${workloadName}-${environment}-${location}-001'
var backEndSubnetName = 'snet-bcke-${workloadName}-${environment}-${location}-001'
var apimSubnetName = 'snet-apim-${workloadName}-${environment}-${location}-001'

var bastionSNNSG = 'nsg-bast-${workloadName}-${environment}-${location}'
var devOpsSNNSG = 'nsg-devops-${workloadName}-${environment}-${location}'
var jumpBoxSNNSG = 'nsg-jbox-${workloadName}-${environment}-${location}'
var appGatewaySNNSG = 'nsg-apgw-${workloadName}-${environment}-${location}'
var privateEndpointSNNSG = 'nsg-prep-${workloadName}-${environment}-${location}'
var backEndSNNSG = 'nsg-bcke-${workloadName}-${environment}-${location}'
var apimSNNSG = 'nsg-apim-${workloadName}-${environment}-${location}'


var publicIPAddressName = 'publicIp'


// Resources - VNet - SubNets
resource vnetApimCs 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: apimCSVNetName
  location: location
  tags: {
    Owner: owner
    // CostCenter: costCenter
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        apimCSVNetNameAddressPrefix
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: [
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionAddressPrefix
          networkSecurityGroup: {
            id: bastionNSG.id
          }
        }
      }
      {
        name: devOpsSubnetName
        properties: {
          addressPrefix: devOpsNameAddressPrefix
          networkSecurityGroup: {
            id: devOpsNSG.id
          }
        }
      }
      {
        name: jumpBoxSubnetName
        properties: {
          addressPrefix: jumpBoxAddressPrefix
          networkSecurityGroup: {
            id: jumpBoxNSG.id
          }
        }
        
      }
      {
        name: appGatewaySubnetName
        properties: {
          addressPrefix: appGatewayAddressPrefix
          networkSecurityGroup: {
            id: appGatewayNSG.id
          }
        }
      }
      {
        name: privateEndpointSubnetName
        properties: {
          addressPrefix: privateEndpointAddressPrefix
          networkSecurityGroup: {
            id: privateEndpointNSG.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: backEndSubnetName
        properties: {
          addressPrefix: backEndAddressPrefix
          networkSecurityGroup: {
            id: backEndNSG.id
          }
        }
      }
      {
        name: apimSubnetName
        properties: {
          addressPrefix: apimAddressPrefix
          networkSecurityGroup: {
            id: apimNSG.id
          }
        }
      }
    ]
  }
}

// Network Security Groups (NSG)
resource bastionNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: bastionSNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp'
        properties: {
          priority: 1000
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource devOpsNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: devOpsSNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp'
        properties: {
          priority: 1000
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
resource jumpBoxNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: jumpBoxSNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp'
        properties: {
          priority: 1000
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
resource appGatewayNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: appGatewaySNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp'
        properties: {
          priority: 1000
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'HealthProbes'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_TLS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_HTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 111
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_AzureLoadBalancer'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAll'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 130
          direction: 'Inbound'
        }
      }
    ]
  }
}
resource privateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: privateEndpointSNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp'
        properties: {
          priority: 1000
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource backEndNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: backEndSNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp'
        properties: {
          priority: 1000
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
resource apimNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: apimSNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp'
        properties: {
          priority: 1000
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Private Endpoint
// // resource privateEndPoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
// //   name: 'PE'
// //   location:location
// //   properties:{
// //     subnet: {
// //       id: resourceId('Microsoft.Network/virtualNetworks/subnets',privateEndpointSubnetName,apimCSVNetName)
// //     }
// //     privateLinkServiceConnections: [
// //       {
// //         name: privateLinkName
// //         properties: {
// //           privateLinkServiceId: functionId
// //           groupIds: [
// //             'AzureFunc'
// //           ]
// //         }
// //       }
// //     ]
// //   }
// // }

// Public IP 
resource pip 'Microsoft.Network/publicIPAddresses@2020-07-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}



// Output section
output apimCSVNetName string = apimCSVNetName
output apimCSVNetId string = vnetApimCs.id

output bastionSubnetName string = bastionSubnetName  
output devOpsSubnetName string = devOpsSubnetName  
output jumpBoxSubnetName string = jumpBoxSubnetName  
output appGatewaySubnetName string = appGatewaySubnetName  
output privateEndpointSubnetName string = privateEndpointSubnetName  
output backEndSubnetName string = backEndSubnetName  
output apimSubnetName string = apimSubnetName

output bastionSubnetid string = '${vnetApimCs.id}/subnets/${bastionSubnetName}'  
output devOpsSubnetid string = '${vnetApimCs.id}/subnets/${devOpsSubnetName}'  
output jumpBoxSubnetid string = '${vnetApimCs.id}/subnets/${jumpBoxSubnetName}'  
output appGatewaySubnetid string = '${vnetApimCs.id}/subnets/${appGatewaySubnetName}'  
output privateEndpointSubnetid string = '${vnetApimCs.id}/subnets/${privateEndpointSubnetName}'  
output backEndSubnetid string = '${vnetApimCs.id}/subnets/${backEndSubnetName}'  
output apimSubnetid string = '${vnetApimCs.id}/subnets/${apimSubnetName}'  

output publicIp string = pip.id

