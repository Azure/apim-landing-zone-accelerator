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
  echo "Please run first the deploy-apim-baseline.sh script"
  echo "Error: Missing environment variable RANDOM_IDENTIFIER. Automatically created by baseline" 1>&2
  exit 6
else
  random_string="${RANDOM_IDENTIFIER}"
fi


#### VALIDATE VARIABLES:
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


# creating tfvars
# create tfvars
echo "Creating terraform variables file..."
cat << EOF > "$script_dir/../../workload-genai/terraform/${ENVIRONMENT_TAG}.tfvars"
location           	= "${AZURE_LOCATION}"
workloadName       	= "${RESOURCE_NAME_PREFIX}"
environment			= "${ENVIRONMENT_TAG}"
identifier			= "${random_string}"
enableTelemetry    	= "${telemetry}"
EOF

echo "Copying backend file to terraform directory..."
cp "$script_dir/../../${ENVIRONMENT_TAG}-backend.hcl" "$script_dir/../../workload-genai/terraform/${ENVIRONMENT_TAG}-backend.hcl"


echo "Initializing Terraform backend..."
cd "$script_dir/../../workload-genai/terraform" || exit

# Delete local state files
rm -rf .terraform
rm -f terraform.lock.hcl
rm -f terraform.tfstate
rm -f terraform.tfstate.backup

terraform init \
	-backend-config="${ENVIRONMENT_TAG}-backend.hcl" \
	-backend-config="key=${ENVIRONMENT_TAG}-genai-lza.tfstate"

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
rm -f "${ENVIRONMENT_TAG}-backend.hcl"

# Setting variables
APIM_SERVICE_NAME="apim-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
APIM_RESOURCE_GROUP="rg-apim-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
NETWORK_RESOURCE_GROUP="rg-networking-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
APPGATEWAY_PIP="pip-appgw-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
API_SUBSCRIPTION_ID="aoai-product-subscription"
MT_PRODUCT1_SUBSCRIPTION_ID="multi-tenant-product1-subscription"
MT_PRODUCT2_SUBSCRIPTION_ID="multi-tenant-product2-subscription"

# Get the access token
TOKEN=$(az account get-access-token --query accessToken --output tsv)

# Call the Azure REST API to get subscription keys
output=$(curl -s -S -X POST -H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json" \
	-H "Content-Length: 0" \
	"https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$APIM_RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE_NAME/subscriptions/$API_SUBSCRIPTION_ID/listSecrets?api-version=2022-08-01")

# Extract the subscription keys
PRIMARY_KEY=$(echo "$output" | jq -r '.primaryKey')

APPGATEWAYPUBLICIPADDRESS=$(az network public-ip show --resource-group "$NETWORK_RESOURCE_GROUP" --name "$APPGATEWAY_PIP" --query ipAddress -o tsv)
testUri="curl -k -H 'Host: ${APPGATEWAY_FQDN}' -H 'Ocp-Apim-Subscription-Key: ${PRIMARY_KEY}' -H 'Content-Type: application/json' https://${APPGATEWAYPUBLICIPADDRESS}/openai/deployments/gpt-35-turbo-16k/chat/completions?api-version=2024-02-15-preview -d '{\"messages\": [{\"role\":\"system\",\"content\":\"You are an AI assistant that helps people find information.\"}]}'"
echo "Test the deployment by running the following command: ${testUri}"
echo -e "\n"

# Call the Azure REST API to get subscription key of multi-tenant product1
mt_product1_sub_output=$(curl -s -S -X POST -H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json" \
	-H "Content-Length: 0" \
	"https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$APIM_RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE_NAME/subscriptions/$MT_PRODUCT1_SUBSCRIPTION_ID/listSecrets?api-version=2022-08-01")

# Extract the subscription keys
MT_PRODUCT1_SUB_PRIMARY_KEY=$(echo "$mt_product1_sub_output" | jq -r '.primaryKey')

testUri="curl -k -H 'Host: ${APPGATEWAY_FQDN}' -H 'Ocp-Apim-Subscription-Key: ${MT_PRODUCT1_SUB_PRIMARY_KEY}' -H 'Content-Type: application/json' https://${APPGATEWAYPUBLICIPADDRESS}/openai/deployments/gpt-35-turbo-16k/chat/completions?api-version=2024-02-15-preview -d '{\"messages\": [{\"role\":\"system\",\"content\":\"You are an AI assistant that helps people find information.\"}]}'"
echo "Test the deployment for multi-tenant Product1 by running the following command: ${testUri}"
echo -e "\n"

# Call the Azure REST API to get subscription key of multi-tenant product2
mt_product2_sub_output=$(curl -s -S -X POST -H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json" \
	-H "Content-Length: 0" \
	"https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$APIM_RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE_NAME/subscriptions/$MT_PRODUCT2_SUBSCRIPTION_ID/listSecrets?api-version=2022-08-01")

# Extract the subscription keys
MT_PRODUCT2_SUB_PRIMARY_KEY=$(echo "$mt_product2_sub_output" | jq -r '.primaryKey')

testUri="curl -k -H 'Host: ${APPGATEWAY_FQDN}' -H 'Ocp-Apim-Subscription-Key: ${MT_PRODUCT2_SUB_PRIMARY_KEY}' -H 'Content-Type: application/json' https://${APPGATEWAYPUBLICIPADDRESS}/openai/deployments/gpt-35-turbo-16k/chat/completions?api-version=2024-02-15-preview -d '{\"messages\": [{\"role\":\"system\",\"content\":\"You are an AI assistant that helps people find information.\"}]}'"
echo "Test the deployment for multi-tenant Product2 by running the following command: ${testUri}"
echo -e "\n"
