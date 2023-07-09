targetScope='subscription'

// Parameters
@description('A short name for the workload being deployed alphanumberic only')
@maxLength(8)
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

@description('The user name to be used as the Administrator for all VMs created by this deployment')
param vmUsername string

@description('The password for the Administrator user for all VMs created by this deployment')
@secure()
param vmPassword string

@description('The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify \'none\' if no agent needed')
@allowed([
  'github'
  'azuredevops'
  'none'
])
param CICDAgentType string

@description('The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format https://dev.azure.com/ORGNAME OR github.com/ORGUSERNAME OR none')
param accountName string

@description('The Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent')
@secure()
param personalAccessToken string

@description('The FQDN for the Application Gateway. Example - api.contoso.com.')
param appGatewayFqdn string

@description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and copy the pfx file to deployment/bicep/gateway/certs/appgw.pfx if custom certificates are to be used')
@allowed([
  'selfsigned'
  'custom'
])
param appGatewayCertType string

param existingKvName string 
param existingKvResourceGroup string 
param existingSecretName string 

param location string = deployment().location

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-002'
var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'

var backendResourceGroupName = 'rg-backend-${resourceSuffix}'

var apimResourceGroupName = 'rg-apim-${resourceSuffix}'

var newOrExisting = ((appGatewayCertType == 'selfsigned')? 'new' : 'existing')

// Resource Names
var apimName = 'apim-${resourceSuffix}'
var appGatewayName = 'appgw-${resourceSuffix}'

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

resource existingKvRG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if(newOrExisting == 'existing') {
  name: existingKvResourceGroup
}

// Modules

module networking './networking/networking.bicep' = {
  name: 'networkingresources'
  scope: resourceGroup(networkingRG.name)
  params: {
    workloadName: workloadName
    deploymentEnvironment: environment
    location: location
  }
}

module backend './backend/backend.bicep' = {
  name: 'backendresources'
  scope: resourceGroup(backendRG.name)
  params: {
    workloadName: workloadName
    environment: environment
    location: location    
    vnetName: networking.outputs.apimCSVNetName
    vnetRG: networkingRG.name
    backendSubnetId: networking.outputs.backEndSubnetid
    privateEndpointSubnetid: networking.outputs.privateEndpointSubnetid
  }
}

var jumpboxSubnetId= networking.outputs.jumpBoxSubnetid
var CICDAgentSubnetId = networking.outputs.CICDAgentSubnetId

module shared './shared/shared.bicep' = {
  dependsOn: [
    networking
  ]
  name: 'sharedresources'
  scope: resourceGroup(sharedRG.name)
  params: {
    accountName: accountName
    CICDAgentSubnetId: CICDAgentSubnetId
    CICDAgentType: CICDAgentType
    environment: environment
    jumpboxSubnetId: jumpboxSubnetId
    location: location
    personalAccessToken: personalAccessToken
    resourceGroupName: sharedRG.name
    resourceSuffix: resourceSuffix
    vmPassword: vmPassword
    vmUsername: vmUsername
    appGatewayName: appGatewayName
    newOrExisting: newOrExisting
  }
}

var newKvName = shared.outputs.keyVaultName

module apimModule 'apim/apim.bicep'  = {
  name: 'apimDeploy'
  scope: resourceGroup(apimRG.name)
  params: {
    apimName: apimName
    apimSubnetId: networking.outputs.apimSubnetid
    location: location
    // appInsightsName: shared.outputs.appInsightsName
    // appInsightsId: shared.outputs.appInsightsId
    // appInsightsInstrumentationKey: shared.outputs.appInsightsInstrumentationKey
  }
}

//Creation of private DNS zones
module dnsZoneModule 'shared/dnszone.bicep'  = {
  name: 'apimDnsZoneDeploy'
  scope: resourceGroup(sharedRG.name)
  dependsOn: [
    apimModule
  ]
  params: {
    vnetName: networking.outputs.apimCSVNetName
    vnetRG: networkingRG.name
    apimName: apimName
    apimRG: apimRG.name
  }
}



module appgwIdentity 'gateway/Identity/Identity.bicep' = {
  scope: resourceGroup(apimRG.name)
  name: 'appGatewayIdentity'
  params: {
    appGatewayName: appGatewayName
    location:     location
  }
}
var appgwIdentityId = appgwIdentity.outputs.appGatewayIdentityId


module keyvaultExisting 'keyvault/keyvault.bicep' = if (newOrExisting == 'existing') {
  name: existingKvName
  scope: existingKvRG
  dependsOn:[
    appgwIdentity
  ]
  params: {
    existingSecretName: existingSecretName
    existingKvResourceGroup: existingKvRG.name
    existingKvName: existingKvName
    appGwManagedIdentity: appgwIdentity
    appGatewayFQDN: appGatewayFqdn
    location: location
    newOrExisting: newOrExisting
    newKvName: newKvName
  }
}



module appgwModule 'gateway/appgw.bicep' = {
  name: 'appgwDeploy'
  scope: resourceGroup(apimRG.name)
  dependsOn: [
    apimModule
    dnsZoneModule
    appgwIdentity
  ]
  params: {
    appGatewayName:                 appGatewayName
    appGatewayFQDN:                 appGatewayFqdn
    location:                       location
    appGatewaySubnetId:             networking.outputs.appGatewaySubnetid
    primaryBackendEndFQDN:          '${apimName}.azure-api.net'
    keyVaultName:                   shared.outputs.keyVaultName
    keyVaultResourceGroupName:      sharedRG.name
    appGatewayCertType:             appGatewayCertType
    appGwManagedIdentityId:           appgwIdentityId
    newOrExistingKeyVault:                  newOrExisting
    existingKeyVaultName:          existingKvName
    existingKeyVaultResourceGroup: existingKvResourceGroup
    existingKeyVaultSecretName:   existingSecretName
  }
}

