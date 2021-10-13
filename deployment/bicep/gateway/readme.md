# Stand-alone Deployment 
These steps are for deploying an Azure Application Gateway standalone, and not a part of the overall Enterprise Scale APIM solution.

## Prequisites
1. A custom domain name (e.g. api.my-custom-domain.com)
2. A pfx certificate (e.g. api.my-custom-domain.com.pfx) with no password set
3. An Azure KeyVault
4. An Azure Virtual Network with a subnet for Application Gateway
5. An Azure API Management with Custom Domains (e.g. api-internal.my-custom-domain.com)

## Steps
0. Update the appgw.test.bicep with your appropriate values
1. pwsh
2. $pfxData = ..\Convert-PfxFiletoBase64Encoding.ps1 -CertPath {{path_to_pfx_file}}
3. az deployment group create --name gw --resource-group rg-apim-example-prod-001 --template-file=appgw.test.bicep  --parameters certificate=$pfxData
