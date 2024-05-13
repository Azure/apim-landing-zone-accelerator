targetScope='resourceGroup'
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
param identifier string

@description('Azure location to which the resources are to be deployed')
param location string

param vnetName string
param privateEndpointSubnetid string
param deploymentSubnetId string
param networkingResourceGroupName string

@description('The name of the shared resource group')
param resourceGroupName string

@description('Standardized suffix text to be added to resource names')
param resourceSuffix string

// Variables - ensure key vault name does not end with '-'
var tempKeyVaultName = take('kv-${workloadName}-${environment}-${location}', 20) // Must be between 3-24 alphanumeric characters 
var uniqueKeyVaultName = take('${tempKeyVaultName}-${identifier}', 24)
var keyVaultName = endsWith(uniqueKeyVaultName, '-') ? substring(uniqueKeyVaultName, 0, length(uniqueKeyVaultName) - 1) : uniqueKeyVaultName
var privateEndpoint_keyvault_Name = 'pep-kv-${resourceSuffix}'

// Resources
module appInsights './modules/azmon.bicep' = {
  name: 'azmon'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    resourceSuffix: resourceSuffix
  }
}

resource key_vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }    
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    accessPolicies: [
    ]
  }
}

module keyvaultPrivateEndpoint './modules/privateendpoint.bicep' = {
  name: privateEndpoint_keyvault_Name
  scope: resourceGroup(networkingResourceGroupName)
  params: {
    location: location
    privateEndpointName: privateEndpoint_keyvault_Name
    groupId: 'vault'
    serviceResourceId: key_vault.id
    vnetName: vnetName
    networkingResourceGroupName: networkingResourceGroupName
    subnetId: privateEndpointSubnetid
    domain:'privatelink.vaultcore.azure.net'
  }
}

module deploy './modules/privatedeploy.bicep' = {
  name: 'deploymenEssentials'
  params: {
    location: location
    resourceSuffix: resourceSuffix
    deploymentSubnetId: deploymentSubnetId
  }
}

// Outputs
output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString
output appInsightsName string=appInsights.outputs.appInsightsName
output appInsightsId string=appInsights.outputs.appInsightsId
output appInsightsInstrumentationKey string=appInsights.outputs.appInsightsInstrumentationKey
output keyVaultName string = key_vault.name
output deploymentIdentityName string = deploy.outputs.deploymentIdentityName
output deploymentStorageName string = deploy.outputs.deploymentStorageName
