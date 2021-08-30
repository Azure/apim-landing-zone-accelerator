targetScope='subscription'
param workloadName string
param location string =  deployment().location
@description('The-- environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

// parameters for azure devops agent 
param vmUsername string
param vmPassword string
param accountName string
param personalAccessToken string

@description('The environment for which the deployment is being executed')
@allowed([
  'github'
  'azuredevops'
  'none'
])
param orgtype string

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
var vmSuffix=environment
// RG Names Declaration
var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var backendResourceGroupName = 'rg-backend-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'
var apimResourceGroupName = 'rg-apim-${resourceSuffix}'

// Create resources name using these objects and pass it as a params in module
var sharedResourceGroupResources = {
  'appInsightsName':'appin-${resourceSuffix}'
  'logAnalyticsWorkspaceName': 'logananalyticsws-${resourceSuffix}'
   'environmentName': environment
   'resourceSuffix' : resourceSuffix
   'vmSuffix' : vmSuffix
   'keyVaultName':'kv-${workloadName}-${environment}' // Must be between 3-24 alphanumeric characters 
}

resource networkingRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkingResourceGroupName
  location: location
}

resource backendRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: backendResourceGroupName
  location: location
}

resource sharedRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
  location: location
}

resource apimRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: apimResourceGroupName
  location: location
}

module networking 'networking.bicep' = {
  name: 'networkingresources'
  scope: resourceGroup(networkingRG.name)
  params: {
    workloadName: workloadName
    environment: environment
  }
}

module backend 'backend.bicep' = {
  name: 'backendresources'
  scope: resourceGroup(backendRG.name)
  params: {

  }
}

// module shared 'shared.bicep' = {
// dependsOn: [
//    networking
//  ]
// shared resource group 
//  for testing -- need a subnet.. 
// var NetworkResourceGroupName = 'rg-network-${resourceSuffix}'
// resource networkRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
//  name: NetworkResourceGroupName
//  location: location
// }

var jumpboxSubnetId= networking.outputs.jumpBoxSubnetid
var agentSubnetId=networking.outputs.devOpsSubnetid



module shared './shared/shared.bicep' = {  dependsOn: [
  networking
]
name: 'sharedresources'
scope: resourceGroup(sharedRG.name)
params: {
  location: location
  sharedResourceGroupResources : sharedResourceGroupResources
  jumpboxSubnetId: jumpboxSubnetId
  agentSubnetId: agentSubnetId
  vmdevopsPassword: vmPassword
  vmdevopsUsername: vmUsername
  personalAccessToken: personalAccessToken
  accountname: accountName
  orgtype: orgtype
  resourceGroupName: sharedRG.name
}
}


module apimModule 'apim/apim.bicep'  = {
  name: 'apimDeploy'
  scope: resourceGroup(apimRG.name)
  params: {
    apimSubnetId: networking.outputs.apimSubnetid
    location: location
    appInsightsName: shared.outputs.appInsightsName
    appInsightsId: shared.outputs.appInsightsId
    appInsightsInstrumentationKey: shared.outputs.appInsightsInstrumentationKey
  }
}
