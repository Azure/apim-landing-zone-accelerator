param keyVaultName    string
param objectId        string
param tenantId        string
param certData        string

resource accessPolicyGrant 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          secrets: [ 
            'get'
            'list' 
          ]
        }                  
      }
    ]
  }
}

resource keyVaultCertificate 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${keyVaultName}/appgw-tls-certificate'
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'application/x-pkcs12'
    value: certData 
  }
  dependsOn: [
    accessPolicyGrant
  ]
}

output secretUri string = keyVaultCertificate.properties.secretUriWithVersion
