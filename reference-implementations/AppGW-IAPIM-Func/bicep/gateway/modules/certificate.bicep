param newOrExistingKv string 
param existingKvName string 
param existingSecretName string 
param existingKvResourceGroup string
param newKeyVaultName  string 
param managedIdentity         object      
param location                string
param appGatewayFQDN          string
@secure()
param certPassword            string
param appGatewayCertType      string
param scope                   string = ((newOrExistingKv == 'new') ? resourceGroup().name : existingKvResourceGroup)

var kvName = ((newOrExistingKv == 'new') ?newKeyVaultName : existingKvName)
var secretName = ((newOrExistingKv == 'new')? replace(appGatewayFQDN,'.', '-') : existingSecretName)
var subjectName='CN=${appGatewayFQDN}'


module grantAccessPolicy '../../keyvault/accessPolicy.bicep'= {
  name: 'grantAccessPolicy'
  scope: resourceGroup(scope)
  params:{
    kvName: kvName
    managedIdentity: managedIdentity
  }
}
// resource accessPolicyGrant 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
//   name: '${kvName}/add'
//   properties: {
//     accessPolicies: [
//       {
//         objectId: managedIdentity.properties.principalId
//         tenantId: managedIdentity.properties.tenantId
//         permissions: {
//           secrets: [ 
//             'get' 
//             'list'
//           ]
//           certificates: [
//             'import'
//             'get'
//             'list'
//             'update'
//             'create'
//           ]
//         }                  
//       }
//     ]
//   }
// }

resource appGatewayCertificate 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (newOrExistingKv == 'new') {
  name: '${secretName}-certificate'
  dependsOn: [
    grantAccessPolicy
  ]
  location: location 
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '6.6'
    arguments: ' -vaultName ${newKeyVaultName} -certificateName ${secretName} -subjectName ${subjectName} -certType ${appGatewayCertType}'
    scriptContent: '''
      param(
      [string] [Parameter(Mandatory=$true)] $vaultName,
      [string] [Parameter(Mandatory=$true)] $certificateName,
      [string] [Parameter(Mandatory=$true)] $subjectName,
      [string] [Parameter(Mandatory=$true)] $certType
      )

      $ErrorActionPreference = 'Stop'
      $DeploymentScriptOutputs = @{}
      if ($certType -eq 'selfsigned') {
        $policy = New-AzKeyVaultCertificatePolicy -SubjectName $subjectName -IssuerName Self -ValidityInMonths 12 -Verbose
        
        # private key is added as a secret that can be retrieved in the ARM template
        Add-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName -CertificatePolicy $policy -Verbose
        
        $newCert = Get-AzKeyVaultCertificate -VaultName $vaultName -Name $certificateName

        # it takes a few seconds for KeyVault to finish
        $tries = 0
        do {
          Write-Host 'Waiting for certificate creation completion...'
          Start-Sleep -Seconds 10
          $operation = Get-AzKeyVaultCertificateOperation -VaultName $vaultName -Name $certificateName
          $tries++

          if ($operation.Status -eq 'failed')
          {
          throw 'Creating certificate $certificateName in vault $vaultName failed with error $($operation.ErrorMessage)'
          }

          if ($tries -gt 120)
          {
          throw 'Timed out waiting for creation of certificate $certificateName in vault $vaultName'
          }
        } while ($operation.Status -ne 'completed')		
      }
      '''
    retentionInterval: 'P1D'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${managedIdentity.subscriptionId}/resourceGroups/${managedIdentity.resourceGroupName}/providers/${managedIdentity.resourceId}': {}
    }
  }
}

module appGatewaySecretsUriFromNewKv 'certificateSecret.bicep' = if(newOrExistingKv == 'new'){
  name: '${secretName}-certificate'
  scope: resourceGroup(scope)
  dependsOn: [
    appGatewayCertificate
  ]
  params: {
    resourceGroupName: scope
    keyVaultName: kvName
    secretName: secretName
  }
}

module appGatewaySecretsUriFromExistingKv 'certificateSecret.bicep' = if(newOrExistingKv == 'existing'){
  name: '${secretName}-certificate'
  scope: resourceGroup(scope)
  dependsOn: [
    appGatewayCertificate
  ]
  params: {
    resourceGroupName: scope
    keyVaultName: kvName
    secretName: secretName
  }
}

output secretUriFromNewKv string = appGatewaySecretsUriFromNewKv.outputs.secretUri
output secretUriFromExistingKv string = appGatewaySecretsUriFromExistingKv.outputs.secretUri

