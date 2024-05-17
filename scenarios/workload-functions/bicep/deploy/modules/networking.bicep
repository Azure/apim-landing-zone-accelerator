param vnetName string
param resourceSuffix string
param deploymentAddressPrefix string = '10.2.8.0/24'

var deploymentSubnetName = 'snet-deploy-${resourceSuffix}'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
}

resource subnetDeploy 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: deploymentSubnetName
  parent: vnet
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

output subnetDeployId string = subnetDeploy.id
output subnetDeployName string = subnetDeploy.name
