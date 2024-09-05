param apiManagementServiceName string
param backends array

resource apiManagementService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementServiceName
}

resource backend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'aoai-lb-pool'
  properties: {
    title: 'aoai-lb-pool'
    type: 'Pool'
    pool: {
      services: [for (backend, i) in backends: {
        id: '/backends/${backend}'
        priority: i%2 == 0 ? 1 : 2
        weight: i+1
      }]
    }  
  }
} 
