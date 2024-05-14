param apimCSVNetNameAddressPrefix string = '10.2.0.0/16'

param appGatewayAddressPrefix string = '10.2.4.0/24'
param apimAddressPrefix string = '10.2.7.0/24'
param privateEndpointAddressPrefix string = '10.2.5.0/24'
param deploymentAddressPrefix string = '10.2.8.0/24'

param location string

@description('Standardized suffix text to be added to resource names')
param resourceSuffix string

// Variables
var owner = 'APIM Const Set'

var apimCSVNetName = 'vnet-apim-cs-${resourceSuffix}'

var appGatewaySubnetName = 'snet-apgw-${resourceSuffix}'
var apimSubnetName = 'snet-apim-${resourceSuffix}'

var appGatewaySNNSG = 'nsg-apgw-${resourceSuffix}'
var apimSNNSG = 'nsg-apim-${resourceSuffix}'

var privateEndpointSubnetName = 'snet-prep-${resourceSuffix}'
var privateEndpointSNNSG = 'nsg-prep-${resourceSuffix}'

var deploymentSubnetName = 'snet-deploy-${resourceSuffix}'

var appGatewayPublicIpName = 'pip-appgw-${resourceSuffix}'

// Resources - VNet - SubNets
resource vnetApimCs 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: apimCSVNetName
  location: location
  tags: {
    Owner: owner
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
        name: appGatewaySubnetName
        properties: {
          addressPrefix: appGatewayAddressPrefix
          networkSecurityGroup: {
            id: appGatewayNSG.id
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
        name: deploymentSubnetName
        properties: {
          addressPrefix: deploymentAddressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          delegations: [
            {
              name: 'Microsoft.ContainerInstance.containerGroups'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
    ]
  }
}

// Network Security Groups (NSG)

resource appGatewayNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: appGatewaySNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHealthProbes'
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
        name: 'AllowClientTrafficToSubnet'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: appGatewayAddressPrefix
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowClientTrafficToFrontendIP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '${pipAppGw.properties.ipAddress}/32'
          access: 'Allow'
          priority: 111
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAzureLoadBalancer'
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
    ]
  }
}

resource apimNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: apimSNNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowApimManagement'
        properties: {
          priority: 2000
          sourceAddressPrefix: 'ApiManagement'
          protocol: 'Tcp'
          destinationPortRange: '3443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureLoadBalancer'
        properties: {
          priority: 2010
          sourceAddressPrefix: 'AzureLoadBalancer'
          protocol: 'Tcp'
          destinationPortRange: '6390'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureTrafficManager'
        properties: {
          priority: 2020
          sourceAddressPrefix: 'AzureTrafficManager'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowStorage'
        properties: {
          priority: 2000
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Storage'
        }
      }
      {
        name: 'AllowSql'
        properties: {
          priority: 2010
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '1433'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'SQL'
        }
      }
      {
        name: 'AllowKeyVault'
        properties: {
          priority: 2020
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureKeyVault'
        }
      }
      {
        name: 'AllowMonitor'
        properties: {
          priority: 2030
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRanges: ['1886', '443']
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureMonitor'
        }
      }
    ]
  }
}

resource privateEndpointNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: privateEndpointSNNSG
  location: location
  properties: {
    securityRules: []
  }
}

// Public IP 
resource pipAppGw 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: appGatewayPublicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: ['1', '2', '3']
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

// Output section
output apimCSVNetName string = apimCSVNetName
output apimCSVNetId string = vnetApimCs.id

output appGatewaySubnetName string = appGatewaySubnetName
output apimSubnetName string = apimSubnetName
output privateEndpointSubnetName string = privateEndpointSubnetName

output appGatewaySubnetid string = '${vnetApimCs.id}/subnets/${appGatewaySubnetName}'
output apimSubnetid string = '${vnetApimCs.id}/subnets/${apimSubnetName}'
output privateEndpointSubnetid string = '${vnetApimCs.id}/subnets/${privateEndpointSubnetName}'

output deploymentSubnetId string = '${vnetApimCs.id}/subnets/${deploymentSubnetName}'
output deploymentSubnetName string = deploymentSubnetName

output publicIpAppGw string = pipAppGw.id
output appGatewayPublicIpName string = appGatewayPublicIpName
