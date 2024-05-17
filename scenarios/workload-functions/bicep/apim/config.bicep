param apimName string

param backendHostName string

var backendUri = '${backendHostName}/api/HttpExample'

resource apiManagementInstance 'Microsoft.ApiManagement/service@2022-09-01-preview' existing = {
  name: apimName
}

resource helloApi 'Microsoft.ApiManagement/service/apis@2020-12-01' = {
  name: 'hello'
  parent: apiManagementInstance
  properties: {
    path: 'hello'
    apiRevision: '1'
    displayName: 'Hello Api'
    description: 'Hello Api'
    subscriptionRequired: true
    serviceUrl: backendUri
    protocols: [
      'https'
    ]
  }
}

resource helloApiPolicies 'Microsoft.ApiManagement/service/apis/policies@2020-12-01' = {
  name: 'policy'
  parent: helloApi
  properties: {
    value: '<!--\r\n    IMPORTANT:\r\n    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.\r\n    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.\r\n    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.\r\n    - To add a policy, place the cursor at the desired insertion point and select a policy from the sidebar.\r\n    - To remove a policy, delete the corresponding policy statement from the policy document.\r\n    - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.\r\n    - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.\r\n    - Policies are applied in the order of their appearance, from the top down.\r\n    - Comments within policy elements are not supported and may disappear. Place your comments between policy elements or at a higher level scope.\r\n-->\r\n<policies>\r\n  <inbound>\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

resource getOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  name: 'say'
  parent: helloApi
  properties: {
      description: 'Say Hello'
      displayName: 'say'
      method: 'GET'
      urlTemplate: '/'
      request: {
          description: 'Request description'
          queryParameters: [
              {
                  name: 'name'
                  required: true
                  type: 'string'
              }
          ]
      }
  }
}


// Basic product
resource basicProduct 'Microsoft.ApiManagement/service/products@2020-12-01' = {
  name: 'hellobasic'
  parent: apiManagementInstance
  properties: {
    displayName: 'hellow-basic'
    description: 'Basic hellow product'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    subscriptionsLimit: 1
    terms: 'These are the terms of use ...'
  }
  dependsOn: [helloApi]
}

resource basicProductPolicies 'Microsoft.ApiManagement/service/products/policies@2020-12-01' = {
  name: 'policy'
  parent: basicProduct
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <rate-limit calls="5" renewal-period="60" />\r\n    <quota calls="100" renewal-period="604800" />\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

resource linkHelloApiToBasicProduct 'Microsoft.ApiManagement/service/products/apis@2020-12-01' = {
  name: 'hello'
  parent: basicProduct
  dependsOn: [helloApi]
}

resource starterProduct 'Microsoft.ApiManagement/service/products@2020-12-01' existing = {
  name: 'starter'
  parent: apiManagementInstance
}

resource linkHelloApiToStarterProduct 'Microsoft.ApiManagement/service/products/apis@2020-12-01' = {
  name: 'hello'
  parent: starterProduct
  dependsOn: [helloApi]
}
