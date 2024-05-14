@description('The name of the Event Hub Namespace')
param eventHubNamespaceName string

@description('The name of the Event Hub')
param eventHubName string

@description('The messaging tier for Event Hub Namespace.')
@allowed([
  'Basic'
  'Standard'
])
param eventHubSku string = 'Standard'

param apimIdentityName string
param apimResourceGroupName string

@description('Location for all resources.')
param location string = resourceGroup().location

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: eventHubSku
    tier: eventHubSku
    capacity: 1
  }
  properties: {
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: eventHubNamespace
  name: eventHubName
  properties: {
    messageRetentionInDays: 7
    partitionCount: 1
  }
}

resource apimIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: apimIdentityName
  scope: resourceGroup(apimResourceGroupName)
}

resource eventHubsDataSenderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '2b629674-e913-4c01-ae53-ef4638d8f975' // https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-event-hubs-data-sender
  scope: tenant()
}

resource assignEventHubsDataSenderToApiManagement 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, eventHubNamespace.name, apimIdentity.id, 'assignEventHubsDataSenderToApiManagement')
  scope: eventHubNamespace
  properties: {
    description: 'Assign EventHubsDataSender role to API Management'
    principalId: apimIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: eventHubsDataSenderRoleDefinition.id
  }
}

output eventHubNamespaceName string = eventHubNamespace.name
output eventHubName string = eventHub.name
