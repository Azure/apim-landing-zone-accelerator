#!/bin/bash

set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# if the script is run with -y flag, it will not prompt for confirmation
if [[ $1 == "-y" ]]; then
	auto_confirm=true
fi

if [[ -f "$script_dir/../../.env" ]]; then
	echo "Loading .env"
	source "$script_dir/../../.env"
fi

if [[ ${#RANDOM_IDENTIFIER} -eq 0 ]]; then
  chars="abcdefghijklmnopqrstuvwxyz"
  random_string=""
  for _ in {1..3}; do
      random_char="${chars:RANDOM%${#chars}:1}"
      random_string+="$random_char"
  done
  echo "RANDOM_IDENTIFIER='$random_string'" >> "$script_dir/../../.env"
else
  random_string="${RANDOM_IDENTIFIER}"
fi


#### VALIDATE VARIABLES:

# tf backend
if [[ ${#TF_BACKEND_STORAGE_ACCOUNT_NAME} -eq 0 ]]; then
  echo 'ERROR: Missing environment variable TF_BACKEND_STORAGE_ACCOUNT_NAME' 1>&2
  exit 6
else
  TF_BACKEND_STORAGE_ACCOUNT_NAME="${TF_BACKEND_STORAGE_ACCOUNT_NAME%$'\r'}"
fi

if [[ ${#TF_BACKEND_CONTAINER_NAME} -eq 0 ]]; then
  echo 'ERROR: Missing environment variable TF_BACKEND_CONTAINER_NAME' 1>&2
  exit 6
else
  TF_BACKEND_CONTAINER_NAME="${TF_BACKEND_CONTAINER_NAME%$'\r'}"
fi

# if [[ ${#TF_BACKEND_KEY} -eq 0 ]]; then
#   echo 'ERROR: Missing environment variable TF_BACKEND_KEY' 1>&2
#   exit 6
# else
#   TF_BACKEND_KEY="${TF_BACKEND_KEY%$'\r'}"
# fi

if [[ ${#TF_BACKEND_RESOURCE_GROUP_NAME} -eq 0 ]]; then
  echo 'ERROR: Missing environment variable TF_BACKEND_RESOURCE_GROUP_NAME' 1>&2
  exit 6
else
  TF_BACKEND_RESOURCE_GROUP_NAME="${TF_BACKEND_RESOURCE_GROUP_NAME%$'\r'}"
fi

if [[ ${#AZURE_LOCATION} -eq 0 ]]; then
  echo 'ERROR: Missing environment variable AZURE_LOCATION' 1>&2
  exit 6
else
  AZURE_LOCATION="${AZURE_LOCATION%$'\r'}"
fi

# params
if [[ ${#AZURE_LOCATION} -eq 0 ]]; then
  echo 'ERROR: Missing environment variable AZURE_LOCATION' 1>&2
  exit 6
else
  AZURE_LOCATION="${AZURE_LOCATION%$'\r'}"
fi

if [[ ${#RESOURCE_NAME_PREFIX} -eq 0 ]]; then
  echo 'ERROR: Missing environment variable RESOURCE_NAME_PREFIX' 1>&2
  exit 6
else
  RESOURCE_NAME_PREFIX="${RESOURCE_NAME_PREFIX%$'\r'}"
fi

if [[ ${#ENVIRONMENT_TAG} -eq 0 ]]; then
  echo 'ERROR: Missing environment variable ENVIRONMENT_TAG' 1>&2
  exit 6
else
  ENVIRONMENT_TAG="${ENVIRONMENT_TAG%$'\r'}"
fi

if [[ ${#APPGATEWAY_FQDN} -eq 0 ]]; then
  echo 'ERROR: Missing environment variable APPGATEWAY_FQDN' 1>&2
  exit 6
else
  APPGATEWAY_FQDN="${APPGATEWAY_FQDN%$'\r'}"
fi

if [[ ${#CERT_TYPE} -eq 0 ]]; then
  echo 'ERROR: Missing environment variable CERT_TYPE' 1>&2
  exit 6
else
  CERT_TYPE="${CERT_TYPE%$'\r'}"
fi

if [[ ${#ENABLE_TELEMETRY} -eq 0 ]]; then
  telemetry=true
fi

if [[ "$CERT_TYPE" == "selfsigned" ]]; then
  cert_data=''
  cert_Pwd=''
else
  cert_data=$(base64 -w 0 "$script_dir/../../certs/appgw.pfx")
  cert_pwd=$(CERT_PWD)
fi



### VALIDATE IF AZ LOGIN IS REQUIRED, SHOW THE SUBSCRIPTION AND CONFIRM IF WANT TO CONTINUE
az account show > /dev/null
if [ $? -ne 0 ]; then
  echo "You need to login to Azure CLI. Run 'az login' and try again."
  exit 6
fi

echo "Using subscription:"
az account show --query "{subscriptionId:id, subscriptionName:name}" --output table

if [[ $auto_confirm == true ]]; then
	echo "auto-confirmation enabled ... continuing"
else
	echo "Do you want to continue? (y/n)"
	read -r response
	if [[ ! $response =~ ^[Yy]$ ]]; then
		echo "Exiting..."
		exit 6
	fi
fi


# VALIDATE BACKEND RESOURCES EXIST
echo "Validating backend resources..."

echo "validating resource group $TF_BACKEND_RESOURCE_GROUP_NAME"
if [ "$(az group exists --name "$TF_BACKEND_RESOURCE_GROUP_NAME")" = true ]; then
  echo "Resource group $TF_BACKEND_RESOURCE_GROUP_NAME exists."
else
  echo "Resouce group $TF_BACKEND_RESOURCE_GROUP_NAME not found" 1>&2
  if [[ $auto_confirm == true ]]; then
		echo "auto-confirmation enabled ... continuing"
		response="y"
	else
		echo "Do you want to create it? (y/n)"
		read -r response
	fi
	if [[ $response =~ ^[Yy]$ ]]; then
		echo "Creating resource group $TF_BACKEND_RESOURCE_GROUP_NAME"
		az group create --name "$TF_BACKEND_RESOURCE_GROUP_NAME" --location "$AZURE_LOCATION" > /dev/null
		echo "Resource group $TF_BACKEND_RESOURCE_GROUP_NAME created."
	else
		echo "Exiting..."
		exit 6
	fi
fi

echo "validating storage account $TF_BACKEND_STORAGE_ACCOUNT_NAME"
if az storage account show --name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" --resource-group "$TF_BACKEND_RESOURCE_GROUP_NAME" > /dev/null 2>&1; then
    echo "Storage account $TF_BACKEND_STORAGE_ACCOUNT_NAME exists in resource group $TF_BACKEND_RESOURCE_GROUP_NAME."
else
	echo "Storage account $TF_BACKEND_STORAGE_ACCOUNT_NAME does not exist in resource group $TF_BACKEND_RESOURCE_GROUP_NAME or an error occurred."
	if [[ $auto_confirm == true ]]; then
		echo "auto-confirmation enabled ... continuing"
		response="y"
	else
		echo "Do you want to create it? (y/n)"
		read -r response
	fi
	if [[ $response =~ ^[Yy]$ ]]; then
		echo "Checking if storage account name is available..."
		if az storage account check-name --name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" --query "nameAvailable" --output tsv; then
			echo "Storage account name $TF_BACKEND_STORAGE_ACCOUNT_NAME is available."
		else
			echo "Storage account name $TF_BACKEND_STORAGE_ACCOUNT_NAME is not available. Exiting..."
			exit 6
		fi
		echo "Creating storage account $TF_BACKEND_STORAGE_ACCOUNT_NAME"
		az storage account create --name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" --resource-group "$TF_BACKEND_RESOURCE_GROUP_NAME" --location "$AZURE_LOCATION" --sku Standard_LRS > /dev/null
		az storage container create --name "$TF_BACKEND_CONTAINER_NAME" --account-name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" > /dev/null
		echo "Storage account $TF_BACKEND_STORAGE_ACCOUNT_NAME created."
	else
		echo "Exiting..."
		exit 6
	fi
fi

echo "validating container $TF_BACKEND_CONTAINER_NAME"

if az storage container show --name "$TF_BACKEND_CONTAINER_NAME" --account-name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" > /dev/null 2>&1; then
  echo "Container $TF_BACKEND_CONTAINER_NAME exists in storage account $TF_BACKEND_STORAGE_ACCOUNT_NAME."
else
	echo "Container $TF_BACKEND_CONTAINER_NAME not found in storage account $TF_BACKEND_STORAGE_ACCOUNT_NAME"
  if [[ $auto_confirm == true ]]; then
		echo "auto-confirmation enabled ... continuing"
		response="y"
	else
		echo "Do you want to create it? (y/n)"
		read -r response
	fi
	if [[ $response =~ ^[Yy]$ ]]; then
		echo "Creating container $TF_BACKEND_CONTAINER_NAME"
		az storage container create --name "$TF_BACKEND_CONTAINER_NAME" --account-name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" > /dev/null
		echo "Container $TF_BACKEND_CONTAINER_NAME created."
	else
		echo "Exiting..."
		exit 6
	fi
fi

echo "Backend resources are valid"

# creating tfvars
# create tfvars
echo "Creating terraform variables file..."
cat << EOF > "$script_dir/../../apim-baseline/terraform/${ENVIRONMENT_TAG}.tfvars"
location           	= "${AZURE_LOCATION}"
workloadName       	= "${RESOURCE_NAME_PREFIX}"
environment        	= "${ENVIRONMENT_TAG}"
identifier			= "${random_string}"
appGatewayFqdn     	= "${APPGATEWAY_FQDN}"
appGatewayCertType 	= "${CERT_TYPE}"
certData			= "${cert_data}"
certKey 			= "${cert_pwd}"
enableTelemetry    	= "${telemetry}"
EOF

echo "Initializing Terraform backend..."
cd "$script_dir/../../apim-baseline/terraform" || exit
terraform init \
	-backend-config="resource_group_name=${TF_BACKEND_RESOURCE_GROUP_NAME}" \
	-backend-config="storage_account_name=${TF_BACKEND_STORAGE_ACCOUNT_NAME}" \
	-backend-config="container_name=${TF_BACKEND_CONTAINER_NAME}" \
	-backend-config="key=${ENVIRONMENT_TAG}-baseline.tfstate"

echo "Creating Terraform plan..."
terraform plan -var-file="${ENVIRONMENT_TAG}.tfvars" -out="${ENVIRONMENT_TAG}.tfplan"
echo "Terraform plan created"

# validate if wants to proceed
if [[ $auto_confirm == true ]]; then
	echo "auto-confirmation enabled ... continuing"
	response="y"
else
	echo "Do you want to create it? (y/n)"
	read -r response
fi

if [[ $response =~ ^[Yy]$ ]]; then
	echo "Applying Terraform plan..."
	terraform apply "${ENVIRONMENT_TAG}.tfplan"
else
	echo "Exiting..."
	exit 6
fi

echo "== Completed terraform deployment"

# remove the plan file, tfvars and terraform.tfstate
rm -f "${ENVIRONMENT_TAG}.tfplan"
rm -f terraform.tfstate
rm -f "${ENVIRONMENT_TAG}.tfvars"

APIM_SERVICE_NAME="apim-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
APIM_RESOURCE_GROUP="rg-apim-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
NETWORK_RESOURCE_GROUP="rg-networking-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
APPGATEWAY_PIP="pip-appgw-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
API_SUBSCRIPTION_NAME="Echo API"

# Get the access token
TOKEN=$(az account get-access-token --query accessToken --output tsv)

# get the subscription id based on the subscription display name
echo "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$APIM_RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE_NAME/subscriptions?api-version=2022-08-01"
API_SUBSCRIPTION_ID=$(curl -s -S -H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json" \
	"https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$APIM_RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE_NAME/subscriptions?api-version=2022-08-01" | jq -r --arg API_SUBSCRIPTION_NAME "$API_SUBSCRIPTION_NAME" '.value[] | select(.properties.displayName == $API_SUBSCRIPTION_NAME) | .name' )

# Call the Azure REST API to get subscription keys
echo "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$APIM_RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE_NAME/subscriptions/$API_SUBSCRIPTION_ID/listSecrets?api-version=2022-08-01"
output=$(curl -s -S -X POST -H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json" \
	-H "Content-Length: 0" \
	"https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$APIM_RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE_NAME/subscriptions/$API_SUBSCRIPTION_ID/listSecrets?api-version=2022-08-01")

# Extract the subscription keys
PRIMARY_KEY=$(echo "$output" | jq -r '.primaryKey')

APPGATEWAYPUBLICIPADDRESS=$(az network public-ip show --resource-group "$NETWORK_RESOURCE_GROUP" --name "$APPGATEWAY_PIP" --query ipAddress -o tsv)
testUri="curl -k -H 'Host: ${APPGATEWAY_FQDN}' -H 'Ocp-Apim-Subscription-Key: ${PRIMARY_KEY}' -H 'Content-Type: application/json' https://${APPGATEWAYPUBLICIPADDRESS}/echo/resource?param1=sample"
echo "Test the deployment by running the following command: ${testUri}"
echo -e "\n"
