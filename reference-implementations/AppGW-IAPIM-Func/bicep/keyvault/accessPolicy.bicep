param kvName string
param managedIdentity object


resource accessPolicyGrant 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${kvName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: managedIdentity.properties.principalId
        tenantId: managedIdentity.properties.tenantId
        permissions: {
          secrets: [ 
            'get' 
            'list'
          ]
          certificates: [
            'import'
            'get'
            'list'
            'update'
            'create'
          ]
        }                  
      }
    ]
  }
}
