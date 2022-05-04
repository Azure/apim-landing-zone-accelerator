//
// Parameters
//

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

@description('Backend subnet id')
param backendSubnetId string
param privateEndpointSubnetid string
param vnetName string
param vnetRG string

param location string

//
// Variables
//
var owner = 'APIM Const Set'

//
// Azure Storage
//
// Azure Storage Sizing
//
// - name: must be globally unique
var storageAccounts_saapimcsbackend_name  = toLower(take(replace('stbknd${workloadName}${environment}${location}', '-',''), 24))
// - location
var storageAccounts_location = location
// - SKU name
var storageAccounts_skuName  = 'Standard_LRS'
// - SKU tier
// var storageAccounts_skuTier  = 'Standard'
// - kind
var storageAccounts_kind  = 'StorageV2'
var functionContentShareName = 'func-contents'

//
// Azure Storage connectivity and security
//
// - min TLS version
var storageAccounts_minTLSVersion = 'TLS1_2'
var privateEndpoint_storageaccount_queue_Name = 'pep-sa-queue-${workloadName}-${environment}-${location}'
var privateEndpoint_storageaccount_blob_Name = 'pep-sa-blob-${workloadName}-${environment}-${location}'
var privateEndpoint_storageaccount_file_Name = 'pep-sa-file-${workloadName}-${environment}-${location}'
var privateEndpoint_storageaccount_table_Name = 'pep-sa-table-${workloadName}-${environment}-${location}'

//
// Azure Application Service Plan
//
// - name
var serverfarms_appsvcplanAPIMCSBackend_name  = 'plan-be-${workloadName}-${environment}-${location}'
// - location
var serverfarms_appsvcplanAPIMCSBackend_location  = location
// Azure Application Service Plan sizing
// - SKU name
var serverfarms_appsvcplanAPIMCSBackend_skuName  = 'P2v2' // dev - 'B1'
// - SKU tier
var serverfarms_appsvcplanAPIMCSBackend_skuTier  = 'PremiumV2' // dev - 'Basic'
// - SKU size
var serverfarms_appsvcplanAPIMCSBackend_skuSize  = 'P2v2' // dev - 'B1'
// - SKU family
var serverfarms_appsvcplanAPIMCSBackend_skuFamily  = 'Pv2' // dev - 'B'
// - SKU capacity
var serverfarms_appsvcplanAPIMCSBackend_skuCapacity  = 1


var sites_funcappAPIMCSBackendMicroServiceA_name = 'func-code-be-${workloadName}-${environment}-${location}'
var sites_funcappAPIMCSBackendMicroServiceA_location  = location
var sites_funcappAPIMCSBackendMicroServiceA_siteHostname   = 'func-code-be-${workloadName}-${environment}-${location}.azurewebsites.net'
var sites_funcappAPIMCSBackendMicroServiceA_repositoryHostname   = 'func-code-be-${workloadName}-${environment}-${location}.scm.azurewebsites.net'
var sites_funcappAPIMCSBackendMicroServiceA_siteName   = 'funccodebe${workloadName}${environment}${location}'
var privateEndpoint_funcappAPIMCSBackendMicroServiceA_name   = 'pep-func-code-be-${workloadName}-${environment}-${location}'


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
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
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


module queueStoragePrivateEndpoint './networking.bicep' = {
  name: privateEndpoint_storageaccount_queue_Name
  params: {
    location: location
    privateEndpointName: privateEndpoint_storageaccount_queue_Name
    privateDnsZoneName: 'queueDnsZone'
    storageAcountName: storageAccounts_saapimcsbackend_name
    groupId: 'queue'
    storageAccountId: storageAccounts_saapimcsbackend_name_resource.id
    vnetName: vnetName
    vnetRG: vnetRG
    subnetId: privateEndpointSubnetid
  }
}

module blobStoragePrivateEndpoint './networking.bicep' = {
  name: privateEndpoint_storageaccount_blob_Name
  params: {
    location: location
    privateEndpointName: privateEndpoint_storageaccount_blob_Name
    privateDnsZoneName: 'blobDnsZone'
    storageAcountName: storageAccounts_saapimcsbackend_name
    groupId: 'blob'
    storageAccountId: storageAccounts_saapimcsbackend_name_resource.id
    vnetName: vnetName
    vnetRG: vnetRG
    subnetId: privateEndpointSubnetid
  }
}

module tableStoragePrivateEndpoint './networking.bicep' = {
  name: privateEndpoint_storageaccount_table_Name
  params: {
    location: location
    privateEndpointName: privateEndpoint_storageaccount_table_Name
    privateDnsZoneName: 'tableDnsZone'
    storageAcountName: storageAccounts_saapimcsbackend_name
    groupId: 'table'
    storageAccountId: storageAccounts_saapimcsbackend_name_resource.id
    vnetName: vnetName
    vnetRG: vnetRG
    subnetId: privateEndpointSubnetid
  }
}

module fileStoragePrivateEndpoint './networking.bicep' = {
  name: privateEndpoint_storageaccount_file_Name
  params: {
    location: location
    privateEndpointName: privateEndpoint_storageaccount_file_Name
    privateDnsZoneName: 'fileDnsZone'
    storageAcountName: storageAccounts_saapimcsbackend_name
    groupId: 'file'
    storageAccountId: storageAccounts_saapimcsbackend_name_resource.id
    vnetName: vnetName
    vnetRG: vnetRG
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
    name:  serverfarms_appsvcplanAPIMCSBackend_skuName
    tier: serverfarms_appsvcplanAPIMCSBackend_skuTier
    size: serverfarms_appsvcplanAPIMCSBackend_skuSize
    family: serverfarms_appsvcplanAPIMCSBackend_skuFamily
    capacity: serverfarms_appsvcplanAPIMCSBackend_skuCapacity
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

// Azure Function App (Linux, .NET Core 3.1)
resource sites_funcappAPIMCSBackendMicroServiceA_name_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: sites_funcappAPIMCSBackendMicroServiceA_name
  location: sites_funcappAPIMCSBackendMicroServiceA_location // 'West Europe'
  tags: {
    Owner: owner
  }
  kind: 'functionapp,linux'
  properties: {
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
    serverFarmId: serverfarms_appsvcplanAPIMCSBackend_name_resource.id
    reserved: true
    isXenon: false
    hyperV: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'dotnet|3.1'
      alwaysOn: true
      http20Enabled: false
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
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
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

// Hostname binding for Azure Function App (Linux, .NET Core 3.1)
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
  scope: resourceGroup(vnetRG)
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
  name: '${privateDNSZoneName}/${uniqueString(vnet.id)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
  dependsOn: [
    privateDnsZones
    privateEndpoint
  ]
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: '${privateEndpoint_funcappAPIMCSBackendMicroServiceA_name}/default'
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
