targetScope='subscription'

@description('The name of the API Management service instance')
param apiManagementServiceName string

param location string = deployment().location

param resourceSuffix string
param apimResourceGroupName string
param apimIdentityName string
param vnetName string
param privateEndpointSubnetid string
param networkingResourceGroupName string

var workloadResourceGroupName = 'rg-openai-${resourceSuffix}'

var eventHubNamespaceName = 'eh-ns-${resourceSuffix}'
var eventHubName = 'apim-utilization-reporting'

var ptuAoaiDeploymentName = 'ptu-${resourceSuffix}'
var paygoOneAoaiDeploymentName = 'paygo-one-${resourceSuffix}'
var paygoTwoAoaiDeploymentName = 'paygo-two-${resourceSuffix}'

resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: workloadResourceGroupName
  location: location
}

module eventHub 'eventhub/eventHub.bicep' = {
  name: 'eventHubDeploy'
  scope: resourceGroup(workloadResourceGroup.name)
  params: {
    eventHubName: eventHubName
    eventHubNamespaceName: eventHubNamespaceName
    location: location
    apimIdentityName: apimIdentityName
    apimResourceGroupName: apimResourceGroupName
  }
}

var openaiDnsZoneName = 'privatelink.openai.azure.com'

module dnsZone '../../apim-baseline/bicep/shared/modules/dnszone.bicep' = {
  scope: resourceGroup(workloadResourceGroup.name)
  name: take('${replace(openaiDnsZoneName, '.', '-')}-deploy', 64)
  params: {
    vnetName: vnetName
    networkingResourceGroupName: networkingResourceGroupName
    domain: openaiDnsZoneName
  }
}

module simulatedPTUDeployment './openai/openai.bicep' = {
  name: 'simulatedPTUDeployment'
  scope: resourceGroup(workloadResourceGroup.name)
  params: {
    name: ptuAoaiDeploymentName
    location: location
    apimIdentityName: apimIdentityName
    apimResourceGroupName: apimResourceGroupName
    deploymentName: 'aoai'
    vnetName: vnetName
    privateEndpointSubnetid: privateEndpointSubnetid
    networkingResourceGroupName: networkingResourceGroupName
  }
  dependsOn: [
    dnsZone
  ]
}

module simulatedPaygoOneDeployment './openai/openai.bicep' = {
  name: 'simulatedPaygoOneDeployment'
  scope: resourceGroup(workloadResourceGroup.name)
  params: {
    name: paygoOneAoaiDeploymentName
    location: location
    apimIdentityName: apimIdentityName
    apimResourceGroupName: apimResourceGroupName
    deploymentName: 'aoai'
    vnetName: vnetName
    privateEndpointSubnetid: privateEndpointSubnetid
    networkingResourceGroupName: networkingResourceGroupName    
  }
  dependsOn: [
    dnsZone
  ]
}

module simulatedPaygoTwoDeployment './openai/openai.bicep' = {
  name: 'simulatedPaygoTwoDeployment'
  scope: resourceGroup(workloadResourceGroup.name)
  params: {
    name: paygoTwoAoaiDeploymentName
    location: location
    apimIdentityName: apimIdentityName
    apimResourceGroupName: apimResourceGroupName
    deploymentName: 'aoai'
    vnetName: vnetName
    privateEndpointSubnetid: privateEndpointSubnetid
    networkingResourceGroupName: networkingResourceGroupName    
  }
  dependsOn: [
    dnsZone
  ]
}

module apiManagement 'apim-policies/apiManagement.bicep' = {
  name: 'apiManagementDeploy'
  scope: resourceGroup(apimResourceGroupName)
  params: {
    apiManagementServiceName: apiManagementServiceName
    ptuDeploymentOneBaseUrl: '${simulatedPTUDeployment.outputs.endpoint}openai'
    payAsYouGoDeploymentOneBaseUrl: '${simulatedPaygoOneDeployment.outputs.endpoint}openai'
    payAsYouGoDeploymentTwoBaseUrl: '${simulatedPaygoTwoDeployment.outputs.endpoint}openai'
    eventHubNamespaceName: eventHub.outputs.eventHubNamespaceName
    eventHubName: eventHub.outputs.eventHubName
    apimIdentityName: apimIdentityName
  }
}

output apiManagementName string = apiManagement.outputs.apiManagementServiceName
output apiManagementAzureOpenAIProductSubscriptionKey string = apiManagement.outputs.apiManagementAzureOpenAIProductSubscriptionKey
