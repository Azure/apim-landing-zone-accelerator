param appGatewayName string
param location string = resourceGroup().location

var appGatewayIdentityId = 'identity-${appGatewayName}'

resource appGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name:     appGatewayIdentityId
  location: location
}
output appGatewayIdentity object = appGatewayIdentity
output appGatewayIdentityId string = appGatewayIdentity.id





