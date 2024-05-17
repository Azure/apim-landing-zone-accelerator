/*
 * Input parameters
*/
@description('The name of the Application Gateawy to be created.')
param appGatewayName string

@description('The FQDN of the Application Gateawy.Must match the TLS Certificate.')
param appGatewayFQDN string

@description('The location of the Application Gateawy to be created')
param location string = resourceGroup().location

@description('The subnet resource id to use for Application Gateway.')
param appGatewaySubnetId string

@description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and pass the CertData and CertKey if custom certificates should be used.')
param appGatewayCertType string

@description('The backend URL of the APIM.')
param primaryBackendEndFQDN string

@description('The Url for the APIM Health Probe.')
param probeUrl string = '/status-0123456789abcdef'

param appGatewayPublicIpName string
param keyVaultName string
param keyVaultResourceGroupName string

param deploymentIdentityName string
param deploymentSubnetId     string
param deploymentStorageName    string

param certKey string
param certData string

var appGatewayIdentityId = 'identity-${appGatewayName}'
var appGatewayFirewallPolicy = 'waf-${appGatewayName}'

resource appGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: appGatewayIdentityId
  location: location
}

module certificate './modules/certificate.bicep' = {
  name: 'certificate'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    managedIdentity: appGatewayIdentity
    deploymentIdentityName: deploymentIdentityName
    deploymentSubnetId: deploymentSubnetId
    deploymentStorageName: deploymentStorageName
    keyVaultName: keyVaultName
    location: location
    appGatewayFQDN: appGatewayFQDN
    appGatewayCertType: appGatewayCertType
    certKey: certKey
    certData: certData
  }
}

resource appGatewayPublicIPAddress 'Microsoft.Network/publicIPAddresses@2019-09-01' existing = {
  name: appGatewayPublicIpName
}

resource appgw_waf_Pol 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-08-01' = {
  name: appGatewayFirewallPolicy
  location: location
  properties: {
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'detection'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
      ]
    }
  }
}

resource appGatewayName_resource 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: appGatewayName
  location: location
  dependsOn: [
    certificate
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appGatewayIdentity.id}': {}
    }
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: appGatewaySubnetId
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: appGatewayFQDN
        properties: {
          keyVaultSecretId: certificate.outputs.secretUri
        }
      }
    ]
    sslPolicy: {
      minProtocolVersion: 'TLSv1_2'
      policyType: 'Custom'
      cipherSuites: [
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256'
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256'
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384'
      ]
    }
    trustedRootCertificates: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: appGatewayPublicIPAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'apim'
        properties: {
          backendAddresses: [
            {
              fqdn: primaryBackendEndFQDN
            }
          ]
        }
      }
      {
        name: 'sink-hole'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'apim-demo-apis-https'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: primaryBackendEndFQDN
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'apim-demo-apis-https')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'apim-demo-apis-https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appGatewayName,
              'appGwPublicFrontendIp'
            )
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, appGatewayFQDN)
          }
          hostnames: [
            appGatewayFQDN
          ]
          requireServerNameIndication: false
        }
      }
    ]
    urlPathMaps: [
      {
        name: 'urlPathMapApim'
        properties: {
          defaultBackendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              appGatewayName,
              'apim'
            )
          }
          defaultBackendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appGatewayName,
              'apim-demo-apis-https'
            )
          }
          pathRules: [
            {
              name: 'echo-api'
              properties: {
                paths: [
                  '/echo/*'
                ]
                backendAddressPool: {
                  id: resourceId(
                    'Microsoft.Network/applicationGateways/backendAddressPools',
                    appGatewayName,
                    'apim'
                  )
                }
                backendHttpSettings: {
                  id: resourceId(
                    'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
                    appGatewayName,
                    'apim-demo-apis-https'
                  )
                }
              }
            }
            {
              name: 'hello-api'
              properties: {
                paths: [
                  '/hello*'
                ]
                backendAddressPool: {
                  id: resourceId(
                    'Microsoft.Network/applicationGateways/backendAddressPools',
                    appGatewayName,
                    'apim'
                  )
                }
                backendHttpSettings: {
                  id: resourceId(
                    'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
                    appGatewayName,
                    'apim-demo-apis-https'
                  )
                }
              }
            }
            {
              name: 'openai-api'
              properties: {
                paths: [
                  '/openai/*'
                ]
                backendAddressPool: {
                  id: resourceId(
                    'Microsoft.Network/applicationGateways/backendAddressPools',
                    appGatewayName,
                    'apim'
                  )
                }
                backendHttpSettings: {
                  id: resourceId(
                    'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
                    appGatewayName,
                    'apim-demo-apis-https'
                  )
                }
              }
            }            
            {
              name: 'default'
              properties: {
                paths: [
                  '/*'
                ]
                backendAddressPool: {
                  id: resourceId(
                    'Microsoft.Network/applicationGateways/backendAddressPools',
                    appGatewayName,
                    'sink-hole'
                  )
                }
                backendHttpSettings: {
                  id: resourceId(
                    'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
                    appGatewayName,
                    'apim-demo-apis-https'
                  )
                }
              }
            }            
          ]
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'apim-demo-apis'
        properties: {
          ruleType: 'PathBasedRouting'
          priority: 100
          urlPathMap: {
            id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', appGatewayName, 'urlPathMapApim')
          }
          httpListener: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/httpListeners',
              appGatewayName,
              'apim-demo-apis-https'
            )
          }
        }
      }
    ]
    probes: [
      {
        name: 'apim-demo-apis-https'
        properties: {
          protocol: 'Https'
          host: primaryBackendEndFQDN
          path: probeUrl
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: []
    redirectConfigurations: []
    firewallPolicy: {
      id: appgw_waf_Pol.id
    }
    enableHttp2: true
    autoscaleConfiguration: {
      minCapacity: 2
      maxCapacity: 3
    }
  }
}

output appGatewayPublicIpAddress string = appGatewayPublicIPAddress.properties.ipAddress
