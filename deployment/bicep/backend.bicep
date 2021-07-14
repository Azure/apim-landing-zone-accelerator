//
// APIM Construction Set
// Backend Resource Group
//
// Contains:
// - Storage Account for Azure Function Apps
// - Application Service Plan for Azure Function Apps
// - Azure Function App with Code Stack
// - Azure Function App with Container
//
//  mbecker@microsoft.com, 2021
//

// Deploy as
//
// az deployment group create -f .\rgAPIMCSBackend.bicep -g <TargetResourceGroup>
//
// Sample
// az deployment group create -f .\rgAPIMCSBackend.bicep -g rgAPIMCSBackend
// *Target Resource Group must exist prior to deployment

//
// Parameters
//
// Azure Storage Account name: must be globally unique
param storageAccounts_saapimcsbackend_name string = 'saapimcsbackend1'
// Azure Application Service Plan name
param serverfarms_appsvcplanAPIMCSBackend_name string = 'appsvcplanAPIMCSBackend'
// Azure Function App name (Code Stack): must be globally unique
param sites_funcappAPIMCSBackendMicroServiceA_name string = 'funcappAPIMCSBackendMicroServiceA1'
// Azure Function App name (Container): must be globally unique
param sites_funcappAPIMCSBackendMicroServiceB_name string = 'funcappAPIMCSBackendMicroServiceB1'

//
// Definitions
//
// Azure Storage Account
resource storageAccounts_saapimcsbackend_name_resource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccounts_saapimcsbackend_name
  location: 'westeurope'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
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

// Azure Application Service Plan
resource serverfarms_appsvcplanAPIMCSBackend_name_resource 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: serverfarms_appsvcplanAPIMCSBackend_name
  location: 'West Europe'
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    freeOfferExpirationTime: '7/18/2021 9:36:43 PM'
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

// Azure Blob Service for Azure Storage Account
resource storageAccounts_saapimcsbackend_name_default 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storageAccounts_saapimcsbackend_name_resource
  name: 'default'
  // mb: this part generates an error on deployment ("sku is read-only")
  //sku: {
    //name: 'Standard_LRS'
    //tier: 'Standard'
  //}
  properties: {
    changeFeed: {
      enabled: false
    }
    restorePolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: false
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
    isVersioningEnabled: false
  }
}

// Azure File Service for Azure Storage Account
resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_saapimcsbackend_name_default 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = {
  parent: storageAccounts_saapimcsbackend_name_resource
  name: 'default'
    // mb: this part generates an error on deployment ("sku is read-only")
  //sku: {
  //    name: 'Standard_LRS'
  //    tier: 'Standard'
  //  }
  properties: {
  // mb: this part generates an error on deployment ("XML not valid")
  //    protocolSettings: {
  //      smb: {}
  //    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: false
      days: 0
    }
  }
}

// Azure Queue Service for Azure Storage Account
resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_saapimcsbackend_name_default 'Microsoft.Storage/storageAccounts/queueServices@2021-04-01' = {
  parent: storageAccounts_saapimcsbackend_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

// Azure Table Service for Azure Storage Account
resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_saapimcsbackend_name_default 'Microsoft.Storage/storageAccounts/tableServices@2021-04-01' = {
  parent: storageAccounts_saapimcsbackend_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

// Azure Function App (Linux, .NET Core 3.1)
resource sites_funcappAPIMCSBackendMicroServiceA_name_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: sites_funcappAPIMCSBackendMicroServiceA_name
  location: 'West Europe'
  kind: 'functionapp,linux'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: 'funcappapimcsbackendmicroservicea.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: 'funcappapimcsbackendmicroservicea.scm.azurewebsites.net'
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
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    hostNamesDisabled: false
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
  }
}

// Azure Function App (Container)
resource sites_funcappAPIMCSBackendMicroServiceB_name_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: sites_funcappAPIMCSBackendMicroServiceB_name
  location: 'West Europe'
  kind: 'functionapp,linux,container'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: 'funcappapimcsbackendmicroserviceb.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: 'funcappapimcsbackendmicroserviceb.scm.azurewebsites.net'
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
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/azure-functions/dotnet:3.0-appservice-quickstart'
      alwaysOn: true
      http20Enabled: false
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    hostNamesDisabled: false
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
  }
}

// Azure Web App for Azure Function App (Linux, .NET Core 3.1)
resource sites_funcappAPIMCSBackendMicroServiceA_name_web 'Microsoft.Web/sites/config@2018-11-01' = {
  parent: sites_funcappAPIMCSBackendMicroServiceA_name_resource
  name: 'web'
  // location: 'West Europe'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'dotnet|3.1'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$funcappAPIMCSBackendMicroServiceA'
    azureStorageAccounts: {}
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    ftpsState: 'AllAllowed'
    reservedInstanceCount: 0
  }
}

// Azure Web App for Azure Function App (Container)
resource sites_funcappAPIMCSBackendMicroServiceB_name_web 'Microsoft.Web/sites/config@2018-11-01' = {
  parent: sites_funcappAPIMCSBackendMicroServiceB_name_resource
  name: 'web'
  //location: 'West Europe'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'DOCKER|mcr.microsoft.com/azure-functions/dotnet:3.0-appservice-quickstart'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$funcappAPIMCSBackendMicroServiceB'
    azureStorageAccounts: {}
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    ftpsState: 'AllAllowed'
    reservedInstanceCount: 0
  }
}

/*
// Azure Function with HttpTRigger1 must be deployed prior to this definition
resource sites_funcappAPIMCSBackendMicroServiceA_name_HttpTrigger1 'Microsoft.Web/sites/functions@2018-11-01' = {
  parent: sites_funcappAPIMCSBackendMicroServiceA_name_resource
  name: 'HttpTrigger1'
  // location: 'West Europe'
  properties: {
    script_root_path_href: 'https://funcappapimcsbackendmicroservicea.azurewebsites.net/admin/vfs/home/site/wwwroot/HttpTrigger1/'
    script_href: 'https://funcappapimcsbackendmicroservicea.azurewebsites.net/admin/vfs/home/site/wwwroot/HttpTrigger1/run.csx'
    config_href: 'https://funcappapimcsbackendmicroservicea.azurewebsites.net/admin/vfs/home/site/wwwroot/HttpTrigger1/function.json'
    href: 'https://funcappapimcsbackendmicroservicea.azurewebsites.net/admin/functions/HttpTrigger1'
    config: {}
    test_data: '{"method":"post","queryStringParams":[],"headers":[],"body":{"name":"Azure"}}'
  }
}
*/

// Hostname binding for Azure Function App (Linux, .NET Core 3.1)
resource sites_funcappAPIMCSBackendMicroServiceA_name_sites_funcappAPIMCSBackendMicroServiceA_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2018-11-01' = {
  parent: sites_funcappAPIMCSBackendMicroServiceA_name_resource
  name: '${sites_funcappAPIMCSBackendMicroServiceA_name}.azurewebsites.net'
  // mb: this part generates an error on deployment ("location is read-only")
  // location: 'West Europe'
  properties: {
    siteName: 'funcappAPIMCSBackendMicroServiceA'
    hostNameType: 'Verified'
  }
}

// Hostname binding for Azure Function App (Container)
resource sites_funcappAPIMCSBackendMicroServiceB_name_sites_funcappAPIMCSBackendMicroServiceB_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2018-11-01' = {
  parent: sites_funcappAPIMCSBackendMicroServiceB_name_resource
  name: '${sites_funcappAPIMCSBackendMicroServiceB_name}.azurewebsites.net'
  // mb: this part generates an error on deployment ("location is read-only")  
  // location: 'West Europe'
  properties: {
    siteName: 'funcappAPIMCSBackendMicroServiceB'
    hostNameType: 'Verified'
  }
}
