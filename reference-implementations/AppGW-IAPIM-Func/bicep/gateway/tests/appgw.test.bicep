var workload =                      'example'
var environment =                   'prod'
var location =                      'southcentralus'
var resourceSuffix =                '${workload}-${environment}-${location}-001'

var apimRG =                        'ES-AppGateway_RG'
var appgw =                         'appgw-${resourceSuffix}'
var appgwFqdn =                     'api.contoso.com'
var appgwSubnet =                   'snet-apgw-${workload}'
var virtualNetworkName =            'vnet-apim-cs-${resourceSuffix}'
var appgwSubnetId =                 '${subscription().id}/resourceGroups/DevSub01_Network_RG/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${appgwSubnet}'
var apimFqdn =                      'api-internal.constoso.com'

var keyVaultName =                  'kv-${workload}-${environment}-002'
var keyVaultRG =                    'ES-AppGateway_RG'
var appGwManagedIdentityId =        '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/ES-AppGateway_RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/appgw-${resourceSuffix}-identity'

var existingKvName = ''
var existingKvRG = ''
var existingKvSecretName = ''
var newOrExistingKv = 'new'

//var certPassword =                  '123456'

module appgwModule '../appgw.bicep' = {
  name: 'appgwDeploy'
  scope: resourceGroup(apimRG)
  params: {
    appGatewayName:                 appgw
    appGatewayFQDN:                 appgwFqdn
    location:                       location
    appGatewaySubnetId:             appgwSubnetId
    primaryBackendEndFQDN:          apimFqdn
    keyVaultName:                   keyVaultName
    keyVaultResourceGroupName:      keyVaultRG
    appGatewayCertType:            'pfx'
    appGwManagedIdentityId: appGwManagedIdentityId
    newOrExistingKeyVault:          newOrExistingKv
    existingKeyVaultName:          existingKvName
    existingKeyVaultResourceGroup: existingKvRG
    existingKeyVaultSecretName: existingKvSecretName
  }
}
