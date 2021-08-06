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
param vmazdevopsUsername string
param vmazdevopsPassword string
param azureDevOpsAccount string
param personalAccessToken string

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
var vmSuffix=environment
// RG Names Declaration
var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'

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


resource sharedRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
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


// shared resource group 


//  for testing -- need a subnet.. 

var NetworkResourceGroupName = 'rg-network-${resourceSuffix}'

resource networkRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: NetworkResourceGroupName
  location: location
}

var jumpboxSubnetId= networking.outputs.jumpBoxSubnetid
var agentSubnetId=networking.outputs.devOpsSubnetid




module shared './shared/shared.bicep' = {
  name: 'sharedresources'
  scope: resourceGroup(sharedRG.name)
  params: {
    location: location
    sharedResourceGroupResources : sharedResourceGroupResources
    jumpboxSubnetId: jumpboxSubnetId
    agentSubnetId: agentSubnetId
    vmazdevopsPassword:vmazdevopsPassword
    vmazdevopsUsername: vmazdevopsUsername
    personalAccessToken: personalAccessToken
    azureDevOpsAccount: azureDevOpsAccount
    resourceGroupName: sharedRG.name
  }
}
