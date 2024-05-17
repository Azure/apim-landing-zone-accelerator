param resourceSuffix string
param location string
param funcAppName string
param deploymentIdentityName string
param deploymentSubnetId     string
param deploymentStorageName    string
param deploymentIdentityResourceGroupName string

param utcValue string = utcNow()

resource functionApp 'Microsoft.Web/sites@2018-11-01' existing = {
  name: funcAppName
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(deploymentIdentityResourceGroupName)
  name: deploymentIdentityName
}

resource generalContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Storage File Data Privileged Contributor
  scope: tenant()
}

resource roleAssignmentFunctionApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: functionApp

  name: guid(generalContributor.id, userAssignedIdentity.id, functionApp.id)
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: generalContributor.id
    principalType: 'ServicePrincipal'
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
      storageAccountName: deploymentStorageName
    }
    containerSettings: {
      subnetIds: [
        {
          id: deploymentSubnetId
        }
      ]
    }      
    scriptContent: 'git clone https://github.com/Azure-Samples/functions-quickstart-javascript; cd functions-quickstart-javascript; zip -r helloworld-latest.zip .; az functionapp deployment source config-zip -g ${resourceGroup().name} -n ${funcAppName} --src helloworld-latest.zip'
    retentionInterval: 'P1D'
    cleanupPreference: 'OnExpiration'
  
  }
  dependsOn: [
    roleAssignmentFunctionApp
  ]
}

