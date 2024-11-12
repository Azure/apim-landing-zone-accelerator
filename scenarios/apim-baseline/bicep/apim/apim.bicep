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

param vnetName string
param networkingResourceGroupName string
param apimRG string
var echoSubscriptionKey = guid('echoPrimaryKey')
/*
 * Resources
*/

var apimIdentityName = 'identity-${apimName}'

resource apimIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: apimIdentityName
  location: location
}

resource apimName_resource 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: apimName
  location: location
  sku:{
    capacity: capacity
    name: skuName
  }
  identity: {
    type:'UserAssigned'
    userAssignedIdentities: {
      '${apimIdentity.id}': {}
    }
  }
  properties:{
    virtualNetworkType: 'Internal'
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnetId
    }
    apiVersionConstraint: {
      minApiVersion: '2019-12-01'
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

resource apimName_appInsightsLogger_resource 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
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

resource apimName_applicationinsights 'Microsoft.ApiManagement/service/diagnostics@2021-08-01' = {
  parent: apimName_resource
  name: 'applicationinsights'
  properties: {
    loggerId: apimName_appInsightsLogger_resource.id
    alwaysLog: 'allErrors'
    sampling: {
      percentage: 100
      samplingType: 'fixed'
    }
    metrics: true
  }
}

module kvaccess './modules/kvaccess.bicep' = {
  name: 'kvaccess'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    managedIdentity:    apimIdentity
    keyVaultName:       keyVaultName
  }
}

//Creation of private DNS zones
module dnsZoneModule './modules/dnsrecords.bicep'  = {
  name: 'apimDnsRecordsDeploy'
  scope: resourceGroup(networkingResourceGroupName)
  dependsOn: [
    apimName_resource
  ]
  params: {
    vnetName: vnetName
    apimName: apimName
    apimRG: apimRG
    networkingResourceGroupName: networkingResourceGroupName  
  }
}

output apimStarterSubscriptionKey string = echoSubscriptionKey
output apimIdentityName string = apimIdentityName
