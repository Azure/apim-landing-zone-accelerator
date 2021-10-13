param appGatewayPrimaryNSG  string
param primarySubnetId       string
param primarySubnetName     string 

var subnet                  = reference('${primarySubnetId}')

resource AppGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: primarySubnetName
  properties: {
    addressPrefix: subnet.addressPrefix
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', appGatewayPrimaryNSG)
    }
  }
}
