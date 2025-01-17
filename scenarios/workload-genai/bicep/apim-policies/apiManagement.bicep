@description('The name of the API Management service instance')
param apiManagementServiceName string

@description('The base url of the first Azure Open AI Service PTU deployment (e.g. https://{your-resource-name}.openai.azure.com/openai/deployments/{deployment-id}/)')
param ptuDeploymentOneBaseUrl string

@description('The base url of the first Azure Open AI Service Pay-As-You-Go deployment (e.g. https://{your-resource-name}.openai.azure.com/openai/deployments/{deployment-id}/)')
param payAsYouGoDeploymentOneBaseUrl string

@description('The base url of the second Azure Open AI Service Pay-As-You-Go deployment (e.g. https://{your-resource-name}.openai.azure.com/openai/deployments/{deployment-id}/)')
param payAsYouGoDeploymentTwoBaseUrl string

@description('The name of the Event Hub Namespace to log to')
param eventHubNamespaceName string

@description('The name of the Event Hub to log utilization data to')
param eventHubName string
param apimIdentityName string

var apimIdentityNameValue = 'apim-identity'

resource apiManagementService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource apimIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: apimIdentityName
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

resource multiTenantProduct1 'Microsoft.ApiManagement/service/products@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'multi-tenant-product1'
  properties: {
    displayName: 'multi-tenant-product1'
    subscriptionRequired: true
    state: 'published'
    approvalRequired: false
  }
}

resource multiTenantProduct2 'Microsoft.ApiManagement/service/products@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'multi-tenant-product2'
  properties: {
    displayName: 'multi-tenant-product2'
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

resource multiTenantProduct1APIAssociation 'Microsoft.ApiManagement/service/products/apis@2023-05-01-preview' = [
  for apiName in azureOpenAIAPINames: {
    name: '${apiManagementServiceName}/${multiTenantProduct1.name}/${apiName}'
  }
]

resource multiTenantProduct2APIAssociation 'Microsoft.ApiManagement/service/products/apis@2023-05-01-preview' = [
  for apiName in azureOpenAIAPINames: {
    name: '${apiManagementServiceName}/${multiTenantProduct2.name}/${apiName}'
  }
]

resource ptuBackendOne 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'ptu-backend-1'
  properties:{
    protocol: 'http'
    url: ptuDeploymentOneBaseUrl
  }
}

resource payAsYouGoBackendOne 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'payg-backend-1'
  properties:{
    protocol: 'http'
    url: payAsYouGoDeploymentOneBaseUrl
  }
}

resource payAsYouGoBackendTwo 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'payg-backend-2'
  properties:{
    protocol: 'http'
    url: payAsYouGoDeploymentTwoBaseUrl
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

resource multiTenantProduct1Subscription 'Microsoft.ApiManagement/service/subscriptions@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'multi-tenant-product1-subscription'
  properties: {
    displayName: 'multi-tenant-product1-subscription'
    state: 'active'
    scope: multiTenantProduct1.id
  }
}

resource multiTenantProduct2Subscription 'Microsoft.ApiManagement/service/subscriptions@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'multi-tenant-product2-subscription'
  properties: {
    displayName: 'multi-tenant-product2-subscription'
    state: 'active'
    scope: multiTenantProduct2.id
  }
}

resource simpleRoundRobinPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'simple-priority-weighted'
  properties: {
    value: loadTextContent('../../policies/fragments/load-balancing/simple-priority-weighted.xml')
    format: 'rawxml'
  }
  dependsOn: [payAsYouGoBackendOne, payAsYouGoBackendTwo]
}



resource simpleRateLimitingPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'rate-limiting-by-tokens'
  properties: {
    value: loadTextContent('../../policies/fragments/rate-limiting/rate-limiting-by-tokens.xml')
    format: 'rawxml'
  }
  dependsOn: [payAsYouGoBackendOne, ptuBackendOne]
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

resource adaptiveRateLimitingWorkAroundPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'rate-limiting-workaround'
  properties: {
    value: loadTextContent('../../policies/fragments/rate-limiting/rate-limiting-workaround.xml')
    format: 'rawxml'
  }
  dependsOn: [payAsYouGoBackendOne, ptuBackendOne]
}

resource usageTrackingEHPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'usage-tracking-with-eventhub'
  properties: {
    value: loadTextContent('../../policies/fragments/usage-tracking/usage-tracking-with-eventhub.xml')
    format: 'rawxml'
  }
  dependsOn: [eventHubLogger]
}

resource usageTrackingWithAppInsightsPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'usage-tracking-with-appinsights'
  properties: {
    value: loadTextContent('../../policies/fragments/usage-tracking/usage-tracking-with-appinsights.xml')
    format: 'rawxml'
  }
  dependsOn: [eventHubLogger]
}

//Load-balancing with Circuit Breaker policy
module apiBackend './load-balancing/backends.bicep' = {
  name: 'apiBackend'
  params: {
    apiManagementServiceName: apiManagementServiceName
    backendUris: ['${ptuDeploymentOneBaseUrl}/', '${payAsYouGoDeploymentOneBaseUrl}/', '${payAsYouGoDeploymentTwoBaseUrl}/']
  }
}

module apiLBPool './load-balancing/lb-pool.bicep' = {
  name: 'apimLBPool'
  params: {
    apiManagementServiceName: apiManagementServiceName
    backends: apiBackend.outputs.backendNames
  }
  dependsOn: [
    apiBackend
  ]
}

//Load the policies
resource azureOpenAIApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  parent: azureOpenAIApi
  name: 'policy'
  properties: {
    value: loadTextContent('../../policies/genai-policy.xml')
    format: 'rawxml'
  }
  dependsOn: [
    simpleRoundRobinPolicyFragment
    adaptiveRateLimitingPolicyFragment
    usageTrackingWithAppInsightsPolicyFragment]
}

resource multiTenantProduct1Policy 'Microsoft.ApiManagement/service/products/policies@2024-06-01-preview' = {
  parent: multiTenantProduct1
  name: 'policy'
  properties: {
    value: loadTextContent('../../policies/multi-tenancy/multi-tenant-product1-policy.xml')
    format: 'rawxml'
  }
  dependsOn: [apiBackend]
}

resource multiTenantProduct2Policy 'Microsoft.ApiManagement/service/products/policies@2024-06-01-preview' = {
  parent: multiTenantProduct2
  name: 'policy'
  properties: {
    value: loadTextContent('../../policies/multi-tenancy/multi-tenant-product2-policy.xml')
    format: 'rawxml'
  }
  dependsOn: [apiBackend]
}

resource apimOpenaiApiUamiNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = {
  name: apimIdentityNameValue
  parent: apiManagementService
  properties: {
    displayName: apimIdentityNameValue
    secret: true
    value: apimIdentity.properties.clientId
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
      identityClientId: apimIdentity.properties.clientId
      name: eventHubName
    }
  }
}

output apiManagementServiceName string = apiManagementService.name
output apiManagementAzureOpenAIProductSubscriptionKey string = azureOpenAIProductSubscription.listSecrets().primaryKey
output apiManagementMultitenantProduct1SubscriptionKey string = multiTenantProduct1Subscription.listSecrets().primaryKey
output apiManagementMultitenantProduct2SubscriptionKey string = multiTenantProduct2Subscription.listSecrets().primaryKey
