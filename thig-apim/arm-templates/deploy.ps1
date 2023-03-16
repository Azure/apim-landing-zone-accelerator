<# 

2. BusinessUnit
3. CostCenter
4. Department
5. Environment
* 1. BusinessOwner
* 6. Operation Owner

Department: HTG
Business Unit: Personal Lines
Cost Center: 356151
Environment: Sandbox
Operational Owner: Kalyan Ponnada
Business Owner: Kalyan Ponnada

#>

# Define runtime variables
$organization = "thig"
$workload = "apim"
$environment = "prd"
$locationLongName = "eastus2"
$locationShortName = "eu2"
$instance = "001"

# Define the resource group name
$resourceGroupName = "rg-$organization-$workload-$environment-$locationShortName-$instance"
Write-Output "Resource group name: $resourceGroupName"

# First delete the resource group if it exists
Write-Output "Deleting resource group rg-thig-apim-prd-eu2-001"
az group delete --name rg-thig-apim-prd-eu2-001 --yes

# Create the resource group
Write-Output "Creating resource group rg-thig-apim-prd-eu2-001"
az group create --name rg-thig-apim-prd-eu2-001 --location $locationLongName

# Deploy the virtual network template
Write-Output "Deploying virtual network template"
az deployment group create --resource-group rg-thig-apim-prd-eu2-001 --template-file ./network/vnet.json --parameters ./network/vnet.parameters.json

# Deploy the API Management template
# Write-Output "Deploying API Management template"
# az deployment group create --resource-group rg-thig-apim-prd-eu2-001 --template-file ./apim/apim.json --parameters ./apim/apim.parameters.json

# Deploy the management jumpbox template
#Write-Output "Deploying management jumpbox template"
# az deployment group create --resource-group rg-thig-apim-prd-eu2-001 --template-file ./jumpbox/jumpbox.json --parameters ./jumpbox/jumpbox.parameters.json

# Exit normally
Exit 0
