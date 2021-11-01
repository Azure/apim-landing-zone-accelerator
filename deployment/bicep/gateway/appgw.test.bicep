var workload =                      'example'
var environment =                   'prod'
var location =                      'southcentralus'
var resourceSuffix =                '${workload}-${environment}-${location}-001'

var apimRG =                        'ES-AppGateway_RG'
var appgw =                         'appgw-${resourceSuffix}'
var appgwFqdn =                     'api.example.com'
var appgwSubnet =                   'snet-apgw-${resourceSuffix}'
var virtualNetworkName =            'vnet-apim-cs-${resourceSuffix}'
var appgwSubnetId =                 '${subscription().id}/resourceGroups/DevSub01_Network_RG/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${appgwSubnet}'
var apimFqdn =                      'api-internal.example.com'

var keyVaultName =                  'kv-example-prod-centralus-001'
var keyVaultRG =                    'rg-shared-example-prod-centralus-001'

module appgwModule 'appgw.bicep' = {
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
    keyVaultName:                   keyVaultName
    keyVaultResourceGroupName:      keyVaultRG
  }
}
