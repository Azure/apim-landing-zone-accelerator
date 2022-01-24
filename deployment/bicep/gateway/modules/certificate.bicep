param keyVaultName            string
param managedIdentity         object      
param location                string
param appGatewayFQDN          string
@secure()
param certPassword            string  

var secretName = replace(appGatewayFQDN,'.', '-')
var certData   = loadFileAsBase64('../certs/appgw.pfx')

resource accessPolicyGrant 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/add'
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
          ]
        }                  
      }
    ]
  }
}

resource appGatewayCertificate 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${secretName}-certificate'
  dependsOn: [
    accessPolicyGrant
  ]
  location: location 
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '6.6'
    scriptContent:'Login-AzAccount -Identity;$ss = Convertto-SecureString -String ${certPassword} -AsPlainText -Force; Import-AzKeyVaultCertificate -Name ${secretName} -VaultName ${keyVaultName} -CertificateString ${certData} -Password $ss'
    retentionInterval: 'P1D'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${managedIdentity.subscriptionId}/resourceGroups/${managedIdentity.resourceGroupName}/providers/${managedIdentity.resourceId}': {}
    }
  }
}

module appGatewaySecretsUri 'certificateSecret.bicep' = {
  name: '${secretName}-certificate'
  dependsOn: [
    appGatewayCertificate
  ]
  params: {
    keyVaultName: keyVaultName
    secretName: secretName
  }
}

output secretUri string = appGatewaySecretsUri.outputs.secretUri
