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

@description('The FQDN for the Application Gateway. Example - api.example.com.')
param appGatewayFqdn string

@description('The pfx password file for the Application Gataeway TLS listener. (base64 encoded)')
param appGatewayCertificateData     string

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
var vmSuffix=environment
// RG Names Declaration
var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var backendResourceGroupName = 'rg-backend-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'
var apimResourceGroupName = 'rg-apim-${resourceSuffix}'

// Resource Names
var apimName = 'apim-${resourceSuffix}'
var appGatewayName = 'appgw-${resourceSuffix}'

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
    workloadName: workloadName
    environment: environment    
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

module apimModule 'apim/apim.bicep'  = {
  name: 'apimDeploy'
  scope: resourceGroup(apimRG.name)
  params: {
    apimName: apimName
    apimSubnetId: networking.outputs.apimSubnetid
    location: location
    appInsightsName: shared.outputs.appInsightsName
    appInsightsId: shared.outputs.appInsightsId
    appInsightsInstrumentationKey: shared.outputs.appInsightsInstrumentationKey
  }
}

//Creation of private DNS zones
module dnsZoneModule 'shared/dnszone.bicep'  = {
  name: 'apimDnsZoneDeploy'
  scope: resourceGroup(sharedRG.name)
  params: {
    vnetName: networking.outputs.apimCSVNetName
    vnetRG: networkingRG.name
    apimName: apimName
    apimRG: apimRG.name
  }
}

module appgwModule 'gateway/appgw.bicep' = {
  name: 'appgwDeploy'
  scope: resourceGroup(apimRG.name)
  dependsOn: [
    apimModule
    dnsZoneModule
  ]
  params: {
    appGatewayName:                 appGatewayName
    appGatewayFQDN:                 appGatewayFqdn
    location:                       location
    appGatewaySubnetId:             networking.outputs.appGatewaySubnetid
    primaryBackendEndFQDN:          '${apimName}.azure-api.net'
    appGatewayCertificateData:      appGatewayCertificateData
    keyVaultName:                   shared.outputs.keyVaultName
    keyVaultResourceGroupName:      sharedRG.name
  }
}
