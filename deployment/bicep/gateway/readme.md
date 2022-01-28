# Testing Deployment 
These steps are for deploying an Azure Application Gateway standalone, and not a part of the overall Enterprise Scale APIM solution. This deployment will create an Application Gateawy with a TLS listener for api.contoso.com using a self-signed certificate stored in Key Vault.  The sample pfx file is located under ./certs and should only be used for testing purposes. 

## Prequisites
1. An Azure KeyVault
1. An Azure Virtual Network with a subnet for Application Gateway
1. An Azure API Management with Custom Domains (e.g. api-internal.contoso.com)

## Test Deployment Steps
1. cd ./deployment/bicep/gateway/tests
1. Update the appgw.test.bicep with your appropriate values
1. az deployment group create --name gw --resource-group rg-apim-example-prod-001 --template-file=appgw.test.bicep
