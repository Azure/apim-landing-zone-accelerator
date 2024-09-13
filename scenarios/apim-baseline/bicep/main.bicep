targetScope = 'subscription'

// Parameters
@description('A short name for the workload being deployed alphanumberic only')
@maxLength(8)
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

param identifier string

@description('The FQDN for the Application Gateway. Example - api.contoso.com.')
param appGatewayFqdn string

@description('The password for the TLS certificate for the Application Gateway.  The pfx file needs to be copied to scenarios/apim-baseline/bicep/gateway/certs/appgw.pfx')
param certKey string = 'placeholder'
param certData string = 'placeholder'

@description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and copy the pfx file to scenarios/apim-baseline/bicep/gateway/certs/appgw.pfx if custom certificates are to be used')
param appGatewayCertType string

param location string = deployment().location

@description('Enable sending usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true
var telemetryId = 'ab1e5729-7452-41b2-9fbb-945cc51d9cd0-${location}-apimsb-main'

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-${identifier}'
var networkingResourceGroupName = 'rg-networking-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'
var apimResourceGroupName = 'rg-apim-${resourceSuffix}'

// Resource Names
var apimName = 'apim-${resourceSuffix}'
var appGatewayName = 'appgw-${resourceSuffix}'

resource networkingRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkingResourceGroupName
  location: location
}

resource sharedRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
  location: location
}

resource apimRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: apimResourceGroupName
  location: location
}

module networking './networking/networking.bicep' = {
  name: 'networkingresources'
  scope: resourceGroup(networkingRG.name)
  params: {
    location: location
    resourceSuffix: resourceSuffix
  }
}

module shared './shared/shared.bicep' = {
  dependsOn: [
    networking
  ]
  name: 'sharedresources'
  scope: resourceGroup(sharedRG.name)
  params: {
    workloadName: workloadName
    environment: environment
    identifier: identifier
    location: location
    resourceGroupName: sharedRG.name
    resourceSuffix: resourceSuffix
    vnetName: networking.outputs.apimCSVNetName
    privateEndpointSubnetid: networking.outputs.privateEndpointSubnetid
    networkingResourceGroupName: networkingRG.name
    deploymentSubnetId: networking.outputs.deploymentSubnetId
  }
}

module apimModule 'apim/apim.bicep' = {
  name: 'apimDeploy'
  scope: resourceGroup(apimRG.name)
  params: {
    apimName: apimName
    apimSubnetId: networking.outputs.apimSubnetid
    location: location
    appInsightsName: shared.outputs.appInsightsName
    appInsightsId: shared.outputs.appInsightsId
    appInsightsInstrumentationKey: shared.outputs.appInsightsInstrumentationKey
    keyVaultName: shared.outputs.keyVaultName
    keyVaultResourceGroupName: sharedRG.name
    networkingResourceGroupName: networkingRG.name
    apimRG: apimRG.name
    vnetName: networking.outputs.apimCSVNetName
  }
}

module appgwModule 'gateway/appgw.bicep' = {
  name: 'appgwDeploy'
  scope: resourceGroup(networkingRG.name)
  dependsOn: [
    apimModule
  ]
  params: {
    appGatewayName: appGatewayName
    appGatewayFQDN: appGatewayFqdn
    location: location
    appGatewaySubnetId: networking.outputs.appGatewaySubnetid
    primaryBackendEndFQDN: '${apimName}.azure-api.net'
    keyVaultName: shared.outputs.keyVaultName
    keyVaultResourceGroupName: sharedRG.name
    appGatewayCertType: appGatewayCertType
    certKey: certKey
    certData: certData
    appGatewayPublicIpName: networking.outputs.appGatewayPublicIpName
    deploymentIdentityName: shared.outputs.deploymentIdentityName
    deploymentSubnetId: networking.outputs.deploymentSubnetId
    deploymentStorageName: shared.outputs.deploymentStorageName
  }
}

@description('Microsoft telemetry deployment.')
#disable-next-line no-deployments-resources
resource telemetrydeployment 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
  location: location
  name: telemetryId
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
      contentVersion: '1.0.0.0'
      resources: {}
    }
  }
}

output resourceSuffix string = resourceSuffix
output networkingResourceGroupName string = networkingResourceGroupName
output sharedResourceGroupName string = sharedResourceGroupName
output apimResourceGroupName string = apimResourceGroupName
output apimName string = apimName
output apimIdentityName string = apimModule.outputs.apimIdentityName
output vnetId string = networking.outputs.apimCSVNetId
output vnetName string = networking.outputs.apimCSVNetName
output privateEndpointSubnetid string = networking.outputs.privateEndpointSubnetid
output deploymentIdentityName string = shared.outputs.deploymentIdentityName
output deploymentSubnetId string = networking.outputs.deploymentSubnetId
output deploymentStorageName string = shared.outputs.deploymentStorageName
output keyVaultName string = shared.outputs.keyVaultName
output appGatewayName string = appGatewayName
output appGatewayPublicIpAddress string = appgwModule.outputs.appGatewayPublicIpAddress
output apimStarterSubscriptionKey string = apimModule.outputs.apimStarterSubscriptionKey
