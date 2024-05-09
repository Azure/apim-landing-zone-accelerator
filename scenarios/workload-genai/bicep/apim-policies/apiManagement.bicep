@description('The name of the API Management service instance')
param apiManagementServiceName string

@description('The base url of the first Azure Open AI Service PTU deployment (e.g. https://{your-resource-name}.openai.azure.com/openai/deployments/{deployment-id}/)')
param ptuDeploymentOneBaseUrl string

@description('The api key of the first Azure Open AI Service PTU deployment')
param ptuDeploymentOneApiKey string

@description('The base url of the first Azure Open AI Service Pay-As-You-Go deployment (e.g. https://{your-resource-name}.openai.azure.com/openai/deployments/{deployment-id}/)')
param payAsYouGoDeploymentOneBaseUrl string

@description('The api key of the first Azure Open AI Service Pay-As-You-Go deployment')
param payAsYouGoDeploymentOneApiKey string

@description('The base url of the second Azure Open AI Service Pay-As-You-Go deployment (e.g. https://{your-resource-name}.openai.azure.com/openai/deployments/{deployment-id}/)')
param payAsYouGoDeploymentTwoBaseUrl string

@description('The api key of the second Azure Open AI Service Pay-As-You-Go deployment')
param payAsYouGoDeploymentTwoApiKey string

@description('The name of the Event Hub Namespace to log to')
param eventHubNamespaceName string

@description('The name of the Event Hub to log utilization data to')
param eventHubName string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource azureOpenAIApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'azure-openai-api'
  properties: {
    path: '/openai'
    displayName: 'AzureOpenAI'
    protocols: ['https']
    value: loadTextContent('./api-specs/openapi-spec.json')
    format: 'openapi+json'
  }
}

resource azureOpenAIProduct 'Microsoft.ApiManagement/service/products@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'aoai-product'
  properties: {
    displayName: 'aoai-product'
    subscriptionRequired: true
    state: 'published'
    approvalRequired: false
  }
}

var azureOpenAIAPINames = [
  azureOpenAIApi.name
]

resource azureOpenAIProductAPIAssociation 'Microsoft.ApiManagement/service/products/apis@2023-05-01-preview' = [
  for apiName in azureOpenAIAPINames: {
    name: '${apiManagementServiceName}/${azureOpenAIProduct.name}/${apiName}'
  }
]

resource ptuBackendOne 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'ptu-backend-1'
  properties:{
    protocol: 'http'
    url: ptuDeploymentOneBaseUrl
    credentials: {
      header: {
        'api-key': [ptuDeploymentOneApiKey]
      }
    }
  }
}

resource payAsYouGoBackendOne 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'payg-backend-1'
  properties:{
    protocol: 'http'
    url: payAsYouGoDeploymentOneBaseUrl
    credentials: {
      header: {
        'api-key': [payAsYouGoDeploymentOneApiKey]
      }
    }
  }
}

resource payAsYouGoBackendTwo 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'payg-backend-2'
  properties:{
    protocol: 'http'
    url: payAsYouGoDeploymentTwoBaseUrl
    credentials: {
      header: {
        'api-key': [payAsYouGoDeploymentTwoApiKey]
      }
    }
  }
}

resource azureOpenAIProductSubscription 'Microsoft.ApiManagement/service/subscriptions@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'aoai-product-subscription'
  properties: {
    displayName: 'aoai-product-subscription'
    state: 'active'
    scope: azureOpenAIProduct.id
  }
}

resource simpleRoundRobinPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'simple-round-robin'
  properties: {
    value: loadTextContent('../../policies/fragments/load-balancing/simple-round-robin.xml')
    format: 'rawxml'
  }
  dependsOn: [payAsYouGoBackendOne, payAsYouGoBackendTwo]
}

resource weightedRoundRobinPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'weighted-round-robin'
  properties: {
    value: loadTextContent('../../policies/fragments/load-balancing/weighted-round-robin.xml')
    format: 'rawxml'
  }
  dependsOn: [payAsYouGoBackendOne, payAsYouGoBackendTwo]
}

resource adaptiveRateLimitingPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'adaptive-rate-limiting'
  properties: {
    value: loadTextContent('../../policies/fragments/rate-limiting/adaptive-rate-limiting.xml')
    format: 'rawxml'
  }
  dependsOn: [payAsYouGoBackendOne, ptuBackendOne]
}

resource retryWithPayAsYouGoPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'retry-with-payg'
  properties: {
    value: loadTextContent('../../policies/fragments/manage-spikes-with-payg/retry-with-payg.xml')
    format: 'rawxml'
  }
}

resource usageTrackingPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'usage-tracking'
  properties: {
    value: loadTextContent('../../policies/fragments/usage-tracking/usage-tracking.xml')
    format: 'rawxml'
  }
  dependsOn: [eventHubLogger]
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: eventHubNamespaceName
}

resource eventHubsDataSenderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: eventHubNamespace
  name: '2b629674-e913-4c01-ae53-ef4638d8f975' // https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-event-hubs-data-sender
}

resource assignEventHubsDataSenderToApiManagement 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, eventHubNamespace.name, apiManagementService.name, 'assignEventHubsDataSenderToApiManagement')
  scope: eventHubNamespace
  properties: {
    description: 'Assign EventHubsDataSender role to API Management'
    principalId: apiManagementService.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: eventHubsDataSenderRoleDefinition.id
  }
}

resource eventHubLogger 'Microsoft.ApiManagement/service/loggers@2022-04-01-preview' = {
  name: 'eventhub-logger'
  parent: apiManagementService
  properties: {
    loggerType: 'azureEventHub'
    description: 'Event hub logger with system-assigned managed identity'
    credentials: {
      endpointAddress: '${eventHubNamespaceName}.servicebus.windows.net'
      identityClientId: 'systemAssigned'
      name: eventHubName
    }
  }
}

output apiManagementServiceName string = apiManagementService.name
output apiManagementAzureOpenAIProductSubscriptionKey string = azureOpenAIProductSubscription.listSecrets().primaryKey
