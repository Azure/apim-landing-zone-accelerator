param keyVaultName            string
param managedIdentity         object      
param location                string
param appGatewayFQDN          string
param certKey                 string
param certData                string
param appGatewayCertType      string
param deploymentIdentityName  string
param deploymentSubnetId      string
param deploymentStorageName   string

var secretName = replace(appGatewayFQDN,'.', '-')
var subjectName='CN=${appGatewayFQDN}'

var certPwd = appGatewayCertType == 'selfsigned' ? 'null' : certKey
var certDataString = appGatewayCertType == 'selfsigned' ? 'null' : certData

resource deploymentIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: deploymentIdentityName
}

resource accessPolicyGrantForCertificate 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
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
            'get'
            'list'
            'update'
            'create'
          ]
        }                  
      }
      {
        objectId: deploymentIdentity.properties.principalId
        tenantId: deploymentIdentity.properties.tenantId
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

resource appGatewayCertificate 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: '${secretName}-certificate'
  dependsOn: [
    accessPolicyGrantForCertificate
  ]
  location: location 
  identity: {
    type: 'userAssigned'
    userAssignedIdentities: {
      '${deploymentIdentity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '6.6'
    storageAccountSettings: {
      storageAccountName: deploymentStorageName
    }
    containerSettings: {
      subnetIds: [
        {
          id: deploymentSubnetId
        }
      ]
    }     
    arguments: ' -vaultName ${keyVaultName} -certificateName ${secretName} -subjectName ${subjectName} -certPwd ${certPwd} -certDataString ${certDataString} -certType ${appGatewayCertType}'
    scriptContent: '''
      param(
      [string] [Parameter(Mandatory=$true)] $vaultName,
      [string] [Parameter(Mandatory=$true)] $certificateName,
      [string] [Parameter(Mandatory=$true)] $subjectName,
      [string] [Parameter(Mandatory=$true)] $certPwd,
      [string] [Parameter(Mandatory=$true)] $certDataString,
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
      else {
        $ss = Convertto-SecureString -String $certPwd -AsPlainText -Force; 
        Import-AzKeyVaultCertificate -Name $certificateName -VaultName $vaultName -CertificateString $certDataString -Password $ss
      }
      '''
    retentionInterval: 'P1D'
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
