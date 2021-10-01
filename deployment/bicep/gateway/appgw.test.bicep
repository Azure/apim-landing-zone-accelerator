@description('The pfx certificate file for the Application Gataeway TLS listener. (base64 encoded)')
param certificate                   string

var workload =                      'example'
var environment =                   'prod'
var location =                      'centralus'
var resourceSuffix =                '${workloadName}-${environment}-${location}-001'

var apimRG =                        'rg-apim-${resourceSuffix}'
var appgw =                         'appgw-${resourceSuffix}'
var appgwFqdn =                     'api.example.com'
var appgwSubnet =                   'snet-apgw-${resourceSuffix}'
var virtualNetworkName =            'vnet-apim-cs-${resourceSuffix}'
var appgwSubnetId =                 '/subscriptions/${subscription().id}/resourceGroups/rg-networking-${resourceSuffix}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${appgwSubnet}'
var apimFqdn =                      'api-internal.example.com'

var keyVaultName =                  'kv-example-prod-centralus-001'
var keyVaultRG =                    'rg-shared-example-prod-centralus-001'

module appgwModule 'gateway/appgw.bicep' = {
  name: 'appgwDeploy'
  scope: resourceGroup(apimRG)
  dependsOn: [
    apimModule
  ]
  params: {
    appGatewayName:                 appgw
    appGatewayFQDN:                 appgwFqdn
    location:                       location
    appGatewaySubnetId:             appgwSubnetId
    primaryBackendEndFQDN:          apimFqdn
    appGatewayCertificateData:      certificate
    keyVaultName:                   keyVaultName
    keyVaultResourceGroupName:      keyVaultRG
  }
}
