targetScope='subscription'

param resourceSuffix string
param networkingResourceGroupName string
param apimResourceGroupName string
param apimName string
param vnetName string
param privateEndpointSubnetid string
param deploymentIdentityName string
param deploymentSubnetId     string
param deploymentStorageName    string
param sharedResourceGroupName string

param location string = deployment().location

var workloadResourceGroupName = 'rg-functions-${resourceSuffix}'

resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: workloadResourceGroupName
  location: location
}

module backend './backend/backend.bicep' = {
  name: 'backendresources'
  scope: resourceGroup(workloadResourceGroup.name)
  params: {
    location: location 
    resourceSuffix: resourceSuffix   
    vnetName: vnetName
    networkingResourceGroupName: networkingResourceGroupName
    privateEndpointSubnetid: privateEndpointSubnetid
  }
}

module deploy './deploy/deploy.bicep' = {
  name: 'deploy'
  scope: resourceGroup(workloadResourceGroup.name)
  params: {
    location: location
    resourceSuffix: resourceSuffix
    funcAppName: backend.outputs.funcAppName
    deploymentIdentityName: deploymentIdentityName
    deploymentSubnetId: deploymentSubnetId
    deploymentStorageName: deploymentStorageName
    deploymentIdentityResourceGroupName: sharedResourceGroupName
  }
  dependsOn: [
    backend
  ]
}

module apimConfig './apim/config.bicep' = {
  name: 'apimConfig'
  scope: resourceGroup(apimResourceGroupName)
  params: {
    apimName: apimName
    backendHostName: backend.outputs.backendHostName
  }
  dependsOn: [
    deploy
  ]
}

output backendHostName string = backend.outputs.backendHostName
