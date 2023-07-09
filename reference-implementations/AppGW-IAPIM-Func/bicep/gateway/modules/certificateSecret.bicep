//param newOrExistingKv string
param resourceGroupName string
param keyVaultName string 
param secretName string 

resource keyVaultCertificate 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' existing = {
  name: '${keyVaultName}/${secretName}'
  scope: resourceGroup(resourceGroupName)
}

output secretUri string = keyVaultCertificate.properties.secretUriWithVersion
