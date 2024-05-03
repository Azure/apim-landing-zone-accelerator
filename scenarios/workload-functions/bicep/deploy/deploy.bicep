param resourceSuffix string
param vnetName string
param location string
param networkingResourceGroupName string
param funcAppName string

var userAssignedIdentityName = 'mi-deploy-${resourceSuffix}'

param utcValue string = utcNow()

module networking './modules/networking.bicep' = {
  name: 'networking-deploy'
  scope: resourceGroup(networkingResourceGroupName)
  params: {
    vnetName: vnetName
    resourceSuffix: resourceSuffix
  }
}

var subnetDeployId = resourceId(networkingResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, 'snet-deploy-${resourceSuffix}')

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
          id: subnetDeployId
          action: 'Allow'
          state: 'Succeeded'
        }
      ]
      defaultAction: 'Deny'
    }
  }
  dependsOn: [
    networking
  ]
}

resource functionApp 'Microsoft.Web/sites@2018-11-01' existing = {
  name: funcAppName
}


resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
}

resource generalContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Storage File Data Privileged Contributor
  scope: tenant()
}

resource roleAssignmentFunctionApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: functionApp

  name: guid(storageFileDataPrivilegedContributor.id, userAssignedIdentity.id, functionApp.id)
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: generalContributor.id
    principalType: 'ServicePrincipal'
  }
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

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
  scope: resourceGroup(networkingResourceGroupName)
  resource subnet 'subnets' existing = {
    name: networking.outputs.subnetDeployName
  }  
}

resource dsFunctionApp 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'deploy-script-${resourceSuffix}'
  location: location
  identity: {
    type: 'userAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  kind: 'AzureCLI'  
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.52.0'
    storageAccountSettings: {
      storageAccountName: storageAccount.name
    }
    containerSettings: {
      subnetIds: [
        {
          id: subnetDeployId
        }
      ]
    }      
    scriptContent: 'git clone https://github.com/Azure-Samples/functions-quickstart-javascript; cd functions-quickstart-javascript; zip -r helloworld-latest.zip .; az functionapp deployment source config-zip -g ${resourceGroup().name} -n ${funcAppName} --src helloworld-latest.zip'
    retentionInterval: 'P1D'
    cleanupPreference: 'OnExpiration'
  
  }
  dependsOn: [
    networking
    roleAssignmentStorage
    roleAssignmentFunctionApp
  ]
}

