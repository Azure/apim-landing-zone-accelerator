# Stand-alone Deployment 
These steps are for deploying an Azure Application Gateway standalone, and not a part of the overall Enterprise Scale APIM solution.

## Prequisites
1. A custom domain name (e.g. api.my-custom-domain.com)
1. A pfx certificate (e.g. api.my-custom-domain.com.pfx)
1. An Azure KeyVault
1. An Azure Virtual Network with a subnet for Application Gateway
1. An Azure API Management with Custom Domains (e.g. api-internal.my-custom-domain.com)

## Steps
1. Update the appgw.test.bicep with your appropriate values
1. cd ./deployment/scripts
1. pwsh
1. $p = ConvertTo-SecureString $PFXPassword -AsPlainText -Force
1. ./Import-AzGatewayCertificate.ps1  -AppGatewayDomain $DomainName  -CertPath $PFXPath -CertPassword $p -KeyVaultName $VaultName
1. cd ../bicep/gateway
1. az deployment group create --name gw --resource-group rg-apim-example-prod-001 --template-file=appgw.test.bicep
