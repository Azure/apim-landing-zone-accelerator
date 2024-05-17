@description('Name of the resource.')
param name string
@description('Location to deploy the resource. Defaults to the location of the resource group.')
param location string = resourceGroup().location
@description('Tags for the resource.')
param tags object = {}

param deploymentName string = 'aoai'

param apimIdentityName string
param apimResourceGroupName string

param vnetName string
param privateEndpointSubnetid string
param networkingResourceGroupName string

@description('Whether to enable public network access. Defaults to Enabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('The model name to be deployed. The model name can be found in the OpenAI portal.')
param modelName string = 'gpt-35-turbo'

@description('The model version to be deployed. At the time of writing this is the latest version is eastus2.')
param modelVersion string = '0613'

resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'OpenAI'
  properties: {
    customSubDomainName: toLower(name)
    publicNetworkAccess: publicNetworkAccess
  }
  sku: {
    name: 'S0'
  }
}

resource cognitiveServicesOpenAIUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' // Cognitive Services OpenAI User
  scope: tenant()
}

resource apimIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(apimResourceGroupName)
  name: apimIdentityName
}

resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cognitiveServices.id, apimIdentity.id, cognitiveServicesOpenAIUser.id)
  scope: cognitiveServices
  properties: {
    principalId: apimIdentity.properties.principalId
    roleDefinitionId: cognitiveServicesOpenAIUser.id
    principalType: 'ServicePrincipal'
  }
}

resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: deploymentName
  parent: cognitiveServices 
  sku: {
    name: 'Standard'
    capacity: 1
  }
  properties: {
    raiPolicyName: 'Microsoft.Default'
    model: {
      format: 'OpenAI'
      name: modelName
      version: modelVersion
    }
  }
}

var privateEndpoint_openai_Name = 'pep-${name}'
var openaiDnsZoneName = 'privatelink.openai.azure.com'

module openaiPrivateEndpoint '../../../apim-baseline/bicep/shared/modules/privateendpoint.bicep' = {
  name: privateEndpoint_openai_Name
  params: {
    location: location
    privateEndpointName: privateEndpoint_openai_Name
    groupId: 'account'
    serviceResourceId: cognitiveServices.id
    vnetName: vnetName
    networkingResourceGroupName: networkingResourceGroupName
    subnetId: privateEndpointSubnetid
    domain: openaiDnsZoneName
    createDnsZone: false
  }
}

@description('ID for the deployed Cognitive Services resource.')
output id string = cognitiveServices.id
@description('Name for the deployed Cognitive Services resource.')
output name string = cognitiveServices.name
@description('Endpoint for the deployed Cognitive Services resource.')
output endpoint string = cognitiveServices.properties.endpoint
@description('Host for the deployed Cognitive Services resource.')
output host string = split(cognitiveServices.properties.endpoint, '/')[2]
