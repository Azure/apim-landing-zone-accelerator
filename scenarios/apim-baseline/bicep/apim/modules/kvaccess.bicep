param keyVaultName            string
param managedIdentity         object   

resource accessPolicyGrant 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: managedIdentity.principalId
        tenantId: managedIdentity.tenantId
        permissions: {
          secrets: [ 
            'get' 
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
        }                  
      }
    ]
  }
}
