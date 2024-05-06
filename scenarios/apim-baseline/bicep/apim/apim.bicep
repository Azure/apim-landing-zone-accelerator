targetScope='resourceGroup'

/*
 * Input parameters
*/

@description('The name of the API Management resource to be created.')
param apimName            string

@description('The subnet resource id to use for APIM.')
@minLength(1)
param apimSubnetId string

@description('The email address of the publisher of the APIM resource.')
@minLength(1)
param publisherEmail string = 'apim@contoso.com'

@description('Company name of the publisher of the APIM resource.')
@minLength(1)
param publisherName string = 'Contoso'

@description('The pricing tier of the APIM resource.')
param skuName string = 'Developer'

@description('The instance size of the APIM resource.')
param capacity int = 1

@description('Location for Azure resources.')
param location string = resourceGroup().location

param appInsightsName string
param appInsightsId string
param appInsightsInstrumentationKey string

param keyVaultName                  string
param keyVaultResourceGroupName     string

var echoSubscriptionKey = guid('echoPrimaryKey')
/*
 * Resources
*/

resource apimName_resource 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: apimName
  location: location
  sku:{
    capacity: capacity
    name: skuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    virtualNetworkType: 'Internal'
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnetId
    }
  }
}

resource echoSubscription 'Microsoft.ApiManagement/service/subscriptions@2020-12-01' = {
  parent: apimName_resource
  name: 'Echo'
  properties: {
    displayName: 'Echo'
    scope: '/products/starter'
    primaryKey: echoSubscriptionKey
  }
}

resource apimName_appInsightsLogger_resource 'Microsoft.ApiManagement/service/loggers@2019-01-01' = {
  parent: apimName_resource
  name: appInsightsName
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

resource apimName_applicationinsights 'Microsoft.ApiManagement/service/diagnostics@2019-01-01' = {
  parent: apimName_resource
  name: 'applicationinsights'
  properties: {
    loggerId: apimName_appInsightsLogger_resource.id
    alwaysLog: 'allErrors'
    sampling: {
      percentage: 100
      samplingType: 'fixed'
    }
  }
}

module kvaccess './modules/kvaccess.bicep' = {
  name: 'kvaccess'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    managedIdentity:    apimName_resource.identity
    keyVaultName:       keyVaultName
  }
}

output apimStarterSubscriptionKey string = echoSubscriptionKey
