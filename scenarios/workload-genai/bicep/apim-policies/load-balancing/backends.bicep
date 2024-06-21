param apiManagementServiceName string
param backendUris array

resource apiManagementService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource backend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = [for (backendUri, i) in backendUris: {
  parent: apiManagementService
  name: 'aoai-${i}'
  properties: {
    url: backendUri
    protocol: 'http'
    circuitBreaker: {
      rules: [{
        name: 'breakerRule'
        failureCondition: {
          count: 1
          interval: 'PT1M'
          statusCodeRanges: [ {
            min: 429
            max: 429
          }]
          errorReasons: ['timeout']
        }
        tripDuration: 'PT1M'
        acceptRetryAfter: true
      }]
    }
  }  
}
]

output backendNames array = [for i in range(0, length(backendUris)): backend[i].name]
