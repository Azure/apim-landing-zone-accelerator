param resourceSuffix string
param location string
param deploymentSubnetId string

var userAssignedIdentityName = 'mi-deploy-${resourceSuffix}'

param storageAccountName string = toLower(take(replace('stdep${resourceSuffix}', '-',''), 24))

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: deploymentSubnetId
          action: 'Allow'
          state: 'Succeeded'
        }
      ]
      defaultAction: 'Deny'
    }
  }
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
}

resource storageFileDataPrivilegedContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '69566ab7-960f-475b-8e7c-b3118f30c6bd' // Storage File Data Privileged Contributor
  scope: tenant()
}

resource roleAssignmentStorage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount

  name: guid(storageFileDataPrivilegedContributor.id, userAssignedIdentity.id, storageAccount.id)
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: storageFileDataPrivilegedContributor.id
    principalType: 'ServicePrincipal'
  }
}

output deploymentIdentityName string = userAssignedIdentityName
output deploymentStorageName string = storageAccountName
