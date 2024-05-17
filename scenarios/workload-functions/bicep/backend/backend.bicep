param resourceSuffix string

param vnetName string
param networkingResourceGroupName string

param privateEndpointSubnetid string

param location string

@description('The language worker runtime to load in the function app.')
@allowed([
  'dotnet'
  'node'
  'python'
  'java'
])
param functionWorkerRuntime string = 'node'

@description('Specifies the OS used for the Azure Function hosting plan.')
@allowed([
  'Windows'
  'Linux'
])
param functionPlanOS string = 'Windows'

@description('Only required for Linux app to represent runtime stack in the format of \'runtime|runtimeVersion\'. For example: \'python|3.9\'')
param linuxFxVersion string = ''

var owner = 'APIM Const Set'

var storageAccounts_saapimcsbackend_name  = toLower(take(replace('stbknd${resourceSuffix}', '-',''), 24))
var storageAccounts_location = location
var storageAccounts_skuName  = 'Standard_LRS'

var storageAccounts_kind  = 'StorageV2'
var functionContentShareName = 'func-contents'


var storageAccounts_minTLSVersion = 'TLS1_2'
var privateEndpoint_storageaccount_queue_Name = 'pep-sa-queue-${resourceSuffix}'
var privateEndpoint_storageaccount_blob_Name = 'pep-sa-blob-${resourceSuffix}'
var privateEndpoint_storageaccount_file_Name = 'pep-sa-file-${resourceSuffix}'
var privateEndpoint_storageaccount_table_Name = 'pep-sa-table-${resourceSuffix}'

var serverfarms_appsvcplanAPIMCSBackend_name  = 'plan-be-${resourceSuffix}'

var serverfarms_appsvcplanAPIMCSBackend_location  = location
var functionAppPlanSku  = 'EP1'
var functionAppPlanSize  = 'EP1'
var functionAppPlanFamily  = 'EP'
var functionAppPlanTier  = 'ElasticPremium'
var functionAppPlanWorkerCount = 1
var isReserved = ((functionPlanOS == 'Linux') ? true : false)

var sites_funcappAPIMCSBackendMicroServiceA_identity = 'mi-func-code-be-${resourceSuffix}'
var sites_funcappAPIMCSBackendMicroServiceA_name = 'func-code-be-${resourceSuffix}'
var sites_funcappAPIMCSBackendMicroServiceA_location  = location
var sites_funcappAPIMCSBackendMicroServiceA_siteHostname   = 'func-code-be-${resourceSuffix}.azurewebsites.net'
var sites_funcappAPIMCSBackendMicroServiceA_repositoryHostname   = 'func-code-be-${resourceSuffix}.scm.azurewebsites.net'
var sites_funcappAPIMCSBackendMicroServiceA_siteName   = 'funccodebe${resourceSuffix}'
var privateEndpoint_funcappAPIMCSBackendMicroServiceA_name   = 'pep-func-code-be-${resourceSuffix}'


module networking './modules/networking.bicep' = {
  name: 'networkingresources'
  scope: resourceGroup(networkingResourceGroupName)
  params: {
    location: location
    resourceSuffix: resourceSuffix  
    vnetName: vnetName
  }
}

var backendSubnetId = networking.outputs.backEndSubnetid

//
// Definitions
//
// Azure Storage Account
resource storageAccounts_saapimcsbackend_name_resource 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccounts_saapimcsbackend_name
  location: storageAccounts_location
  tags: {
    Owner: owner
  }
  sku: {
    name: storageAccounts_skuName
  }
  kind: storageAccounts_kind
  properties: {
    minimumTlsVersion: storageAccounts_minTLSVersion
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}


module queueStoragePrivateEndpoint '../../../apim-baseline/bicep/shared/modules/privateendpoint.bicep' = {
  name: privateEndpoint_storageaccount_queue_Name
  params: {
    location: location
    privateEndpointName: privateEndpoint_storageaccount_queue_Name
    domain: 'privatelink.queue.${environment().suffixes.storage}'
    groupId: 'queue'
    serviceResourceId: storageAccounts_saapimcsbackend_name_resource.id
    vnetName: vnetName
    networkingResourceGroupName: networkingResourceGroupName
    subnetId: privateEndpointSubnetid
  }
}

module blobStoragePrivateEndpoint '../../../apim-baseline/bicep/shared/modules/privateendpoint.bicep' = {
  name: privateEndpoint_storageaccount_blob_Name
  params: {
    location: location
    privateEndpointName: privateEndpoint_storageaccount_blob_Name
    groupId: 'blob'
    domain: 'privatelink.blob.${environment().suffixes.storage}'
    serviceResourceId: storageAccounts_saapimcsbackend_name_resource.id
    vnetName: vnetName
    networkingResourceGroupName: networkingResourceGroupName
    subnetId: privateEndpointSubnetid
  }
}

module tableStoragePrivateEndpoint '../../../apim-baseline/bicep/shared/modules/privateendpoint.bicep' = {
  name: privateEndpoint_storageaccount_table_Name
  params: {
    location: location
    privateEndpointName: privateEndpoint_storageaccount_table_Name
    groupId: 'table'
    domain: 'privatelink.table.${environment().suffixes.storage}'
    serviceResourceId: storageAccounts_saapimcsbackend_name_resource.id
    vnetName: vnetName
    networkingResourceGroupName: networkingResourceGroupName
    subnetId: privateEndpointSubnetid
  }
}

module fileStoragePrivateEndpoint '../../../apim-baseline/bicep/shared/modules/privateendpoint.bicep' = {
  name: privateEndpoint_storageaccount_file_Name
  params: {
    location: location
    privateEndpointName: privateEndpoint_storageaccount_file_Name
    groupId: 'file'
    domain: 'privatelink.file.${environment().suffixes.storage}'
    serviceResourceId: storageAccounts_saapimcsbackend_name_resource.id
    vnetName: vnetName
    networkingResourceGroupName: networkingResourceGroupName
    subnetId: privateEndpointSubnetid
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${storageAccounts_saapimcsbackend_name_resource.name}/default/${functionContentShareName}'
}

// Azure Application Service Plan
resource serverfarms_appsvcplanAPIMCSBackend_name_resource 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: serverfarms_appsvcplanAPIMCSBackend_name
  location: serverfarms_appsvcplanAPIMCSBackend_location
  tags: {
    Owner: owner
  }
  sku: {
    name:  functionAppPlanSku
    tier: functionAppPlanTier
    size: functionAppPlanSize
    family: functionAppPlanFamily
  }
  kind: 'elastic'
  properties: {
    maximumElasticWorkerCount: functionAppPlanWorkerCount
    reserved: isReserved
  }
}

resource funcAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: sites_funcappAPIMCSBackendMicroServiceA_identity
  location: sites_funcappAPIMCSBackendMicroServiceA_location
}

// Azure Function App (Linux, .NET Core 3.1)
resource sites_funcappAPIMCSBackendMicroServiceA_name_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: sites_funcappAPIMCSBackendMicroServiceA_name
  location: sites_funcappAPIMCSBackendMicroServiceA_location
  tags: {
    Owner: owner
  }
  kind: (isReserved ? 'functionapp,linux' : 'functionapp')
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${funcAppIdentity.id}': {}
    }
  }
  properties: {
    reserved: isReserved
    serverFarmId: serverfarms_appsvcplanAPIMCSBackend_name_resource.id
    enabled: true
    hostNameSslStates: [
      {
        name: sites_funcappAPIMCSBackendMicroServiceA_siteHostname
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: sites_funcappAPIMCSBackendMicroServiceA_repositoryHostname
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    siteConfig: {
      linuxFxVersion: (isReserved ? linuxFxVersion : null)
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccounts_saapimcsbackend_name};AccountKey=${storageAccounts_saapimcsbackend_name_resource.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccounts_saapimcsbackend_name};AccountKey=${storageAccounts_saapimcsbackend_name_resource.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionContentShareName
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
      ]      
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    hostNamesDisabled: false
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
  }
  dependsOn: [
    queueStoragePrivateEndpoint
    blobStoragePrivateEndpoint
    tableStoragePrivateEndpoint
    fileStoragePrivateEndpoint
  ]
}

resource sites_funcappAPIMCSBackendMicroServiceA_name_sites_funcappAPIMCSBackendMicroServiceA_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2018-11-01' = {
  parent: sites_funcappAPIMCSBackendMicroServiceA_name_resource
  name: '${sites_funcappAPIMCSBackendMicroServiceA_name}.azurewebsites.net'
  properties: {
    siteName: sites_funcappAPIMCSBackendMicroServiceA_siteName
    hostNameType: 'Verified'
  }
}

resource planNetworkConfig 'Microsoft.Web/sites/networkConfig@2021-01-01' = {
  parent: sites_funcappAPIMCSBackendMicroServiceA_name_resource
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: backendSubnetId
    swiftSupported: true
  }
}

var privateDNSZoneName = 'privatelink.azurewebsites.net'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(networkingResourceGroupName)
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: privateEndpoint_funcappAPIMCSBackendMicroServiceA_name
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetid
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpoint_funcappAPIMCSBackendMicroServiceA_name
        properties: {
          privateLinkServiceId: sites_funcappAPIMCSBackendMicroServiceA_name_resource.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZoneName
  location: 'global'
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDnsZones
  name: uniqueString(vnet.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
  dependsOn: [
    privateEndpoint
  ]
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${sites_funcappAPIMCSBackendMicroServiceA_siteHostname}-azurewebsites-net'
        properties: {
          privateDnsZoneId: privateDnsZones.id
        }
      }
    ]
  }
  dependsOn: [
    privateDnsZoneLink
  ]
}

output funcAppIdentityName string = funcAppIdentity.name
output funcAppName string = sites_funcappAPIMCSBackendMicroServiceA_name_resource.name
output backendHostName string = 'https://${sites_funcappAPIMCSBackendMicroServiceA_name}.azurewebsites.net'
