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

@description('The name of the shared resource group')
param resourceGroupName string

@description('Standardized suffix text to be added to resource names')
param resourceSuffix string

// Variables - ensure key vault name does not end with '-'
var tempKeyVaultName = take('kv-${workloadName}-${environment}-${location}', 20) // Must be between 3-24 alphanumeric characters 
var uniqueKeyVaultName = take('${tempKeyVaultName}-${identifier}', 24)
var keyVaultName = endsWith(uniqueKeyVaultName, '-') ? substring(uniqueKeyVaultName, 0, length(uniqueKeyVaultName) - 1) : uniqueKeyVaultName

// Resources
module appInsights './azmon.bicep' = {
  name: 'azmon'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    resourceSuffix: resourceSuffix
  }
}
resource key_vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }    
    accessPolicies: [
    ]
  }
}

// Outputs
output appInsightsConnectionString string = appInsights.outputs.appInsightsConnectionString
output appInsightsName string=appInsights.outputs.appInsightsName
output appInsightsId string=appInsights.outputs.appInsightsId
output appInsightsInstrumentationKey string=appInsights.outputs.appInsightsInstrumentationKey
output keyVaultName string = key_vault.name
