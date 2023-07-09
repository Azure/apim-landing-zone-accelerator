
param existingSecretName string 
param existingKvName string 
param existingKvResourceGroup string
param newKvName string
param appGwManagedIdentity object
param appGatewayFQDN string
param appGatewayCertType string = 'custom'
param location string 

param newOrExisting string 


resource key_vault_existing 'Microsoft.KeyVault/vaults@2019-09-01' existing  ={
  name: existingKvName
  scope: resourceGroup(existingKvResourceGroup)
}

module kvCertificate '../gateway/modules/certificate.bicep'={
  name: existingSecretName
  params: {
    existingSecretName: existingSecretName
    existingKvName: existingKvName
    existingKvResourceGroup: existingKvResourceGroup
    appGatewayCertType: appGatewayCertType
    appGatewayFQDN: appGatewayFQDN
    managedIdentity: appGwManagedIdentity
    location: location
    newOrExistingKv: newOrExisting
    newKeyVaultName: newKvName
  }
  dependsOn: [
    key_vault_existing
  ]
}

output secretUri string = kvCertificate.outputs.secretUriFromExistingKv

