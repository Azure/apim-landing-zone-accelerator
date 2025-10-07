#!/bin/bash

set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
env_file="./.env"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --auto-confirm|-y) auto_confirm=true; shift 2 ;;
    --delete-local-state|-d) delete_local_state=true; shift ;;
    *) echo "Invalid argument: $1"; exit 1 ;;
  esac
done

# show a message if auto confirm or delete local state is set
if [[ $auto_confirm == true ]]; then
  echo "Auto-confirmation enabled, proceeding without prompts."
fi
if [[ $delete_local_state == true ]]; then
  echo "Delete local state enabled, local Terraform state files will be removed."
fi




if [[ -f "$env_file" ]]; then
	echo "Found .env, sourcing it..."
  cat "$env_file"
	source "$env_file"
else
  echo "###########################"
  echo "Error: .env file not found in the current directory."
  echo "###########################"
  exit 1
fi


if [[ ${#RANDOM_IDENTIFIER} -eq 0 ]]; then
  chars="abcdefghijklmnopqrstuvwxyz"
  random_string=""
  for _ in {1..3}; do
      random_char="${chars:RANDOM%${#chars}:1}"
      random_string+="$random_char"
  done
  echo "RANDOM_IDENTIFIER='$random_string'" >> "$env_file"
else
  random_string="${RANDOM_IDENTIFIER}"
fi

#### VALIDATE VARIABLES:

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
  #cert_data=''
  #cert_Pwd=''

cat << EOF > "$script_dir/tmp-self-signed-cert.conf"

[ req ]
default_bits       = 4096
distinguished_name = req_distinguished_name
req_extensions     = req_ext
x509_extensions    = v3_req
prompt             = no

[ req_distinguished_name ]
CN = ${APPGATEWAY_FQDN}

[ req_ext ]
subjectAltName = @alt_names

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${APPGATEWAY_FQDN}
EOF

openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
  -keyout "$script_dir/apim-self-signed.key" \
  -out "$script_dir/apim-self-signed.crt" \
  -config "$script_dir/tmp-self-signed-cert.conf" 

openssl pkcs12 -export \
  -out "$script_dir/../../apim-baseline/terraform/modules/gateway/apim-self-signed-cert.pfx" \
  -inkey "$script_dir/apim-self-signed.key" \
  -in "$script_dir/apim-self-signed.crt" \
  -passout pass:SelfSignedForLabPurposesChangeMe!


else
  cert_data=$(base64 -w 0 "$script_dir/../../certs/appgw.pfx")
  cert_pwd=$(CERT_PWD)
fi

### MULTI REGION AND ZONE REDUNDANT UPDATES
if [[ "$MULTI_REGION" == "true" ]]; then
  echo "Multi Region is enabled, checking for AZURE_LOCATION2..."
  if [[ ${#AZURE_LOCATION2} -eq 0 ]]; then
    echo 'ERROR: Multi Region was set to true, however environment variable AZURE_LOCATION2 is missing' 1>&2
    exit 6
  else
    AZURE_LOCATION2="${AZURE_LOCATION2%$'\r'}"
    MULTI_REGION="${MULTI_REGION%$'\r'}"
    echo "Multi Region is enabled, using AZURE_LOCATION2: ${AZURE_LOCATION2}"
  fi
else
  echo "Multi Region is not enabled, AZURE_LOCATION2 will not be used."
  MULTI_REGION="${MULTI_REGION%$'\r'}"
  AZURE_LOCATION2=""
fi

if [[ ${#ZONE_REDUNDANT} -eq 0 ]]; then
  # Assume false if not set
  ZONE_REDUNDANT="false"
else
  ZONE_REDUNDANT="${ZONE_REDUNDANT%$'\r'}"
fi


### VALIDATE IF AZ LOGIN IS REQUIRED, SHOW THE SUBSCRIPTION AND CONFIRM IF WANT TO CONTINUE
az account show > /dev/null
if [ $? -ne 0 ]; then
  echo "You need to login to Azure CLI. Run 'az login' and try again."
  exit 6
fi
echo -e "\n"
echo "Currently selected subscription:"
az account show --query "{subscriptionId:id, subscriptionName:name}" --output table
echo -e "\n"
echo "If you want to change the subscription, run 'az account set --subscription <subscriptionId>'"
echo -e "\n"


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

# Get the current subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)


# creating tfvars
# create tfvars
echo "Creating terraform variables file..."
cat << EOF > "$script_dir/../../apim-baseline/terraform/${ENVIRONMENT_TAG}.tfvars"
location           	 = "${AZURE_LOCATION}"
workloadName       	 = "${RESOURCE_NAME_PREFIX}"
environment        	 = "${ENVIRONMENT_TAG}"
identifier			     = "${random_string}"
appGatewayFqdn     	 = "${APPGATEWAY_FQDN}"
appGatewayCertType 	 = "${CERT_TYPE}"
certData			       = "${cert_data}"
certKey 			       = "${cert_pwd}"
enableTelemetry    	 = "${telemetry}"
multiRegionEnabled 	 = "${MULTI_REGION}"
zoneRedundantEnabled = "${ZONE_REDUNDANT}"
locationSecond 	     = "${AZURE_LOCATION2}"
subscription_id      = "${SUBSCRIPTION_ID}"
EOF

cat "$script_dir/../../apim-baseline/terraform/${ENVIRONMENT_TAG}.tfvars"

#### Init Terraform with Backend or local storage based on presence of backend.hcl file
backend_hcl_file="./${ENVIRONMENT_TAG}-backend.hcl"

if [[ -f "$backend_hcl_file" ]]; then
  echo "Found existing backend file, using it..."

  echo "Copying backend file to terraform directory..."
  cp "$backend_hcl_file" "../../apim-baseline/terraform/${ENVIRONMENT_TAG}-backend.hcl"
  cat "../../apim-baseline/terraform/${ENVIRONMENT_TAG}-backend.hcl"
  echo "Initializing Terraform backend..."
  cd "../../apim-baseline/terraform" || exit

  echo "=="
  echo "== Starting terraform deployment baseline"
  echo "=="

  # Delete local state files
  echo "== deleting local state files"
  rm -rf .terraform
  rm -f terraform.lock.hcl
  rm -f terraform.tfstate
  rm -f terraform.tfstate.backup


  terraform init \
    -backend-config="${ENVIRONMENT_TAG}-backend.hcl" \
    -backend-config="key=${ENVIRONMENT_TAG}-baseline-lza.tfstate"


else

  echo "Initializing Terraform with local backend..."
  cd "../../apim-baseline/terraform" || exit
  terraform init -backend=false

fi

# Check if there is an existing local state file
if [[ -f "${ENVIRONMENT_TAG}.tfstate" ]]; then
  echo -n "Found existing local state files..."
  if [[ "$delete_local_state" == "true" ]]; then
    echo "Deleting local Terraform state files..."
    rm -f "${ENVIRONMENT_TAG}.tfplan"
    rm -f "${ENVIRONMENT_TAG}.tfvars"
    rm -f "${ENVIRONMENT_TAG}-backend.hcl"
  else
    echo "and reusing it. Use --delete-local-state to remove it."
  fi
fi

### Create the Terraform plan

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



if [[ "$MULTI_REGION" == "true" ]]; then
  
  APPGWNAME_UNDERSCORES="${APPGATEWAY_FQDN//./_}"
  TRAFFIC_MANAGER_FQDN="${APPGWNAME_UNDERSCORES}.trafficmanager.net"
  testUri="curl -k -v https://${TRAFFIC_MANAGER_FQDN}/status-0123456789abcdef"
  echo "Test the deployment by running the following command: ${testUri}"
  echo -e "\n"

else
  APIM_SERVICE_NAME="apim-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
  APIM_RESOURCE_GROUP="rg-apim-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
  NETWORK_RESOURCE_GROUP="rg-networking-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
  APPGATEWAY_PIP="pip-appgw-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"

  SUBSCRIPTION_ID=$(az account show --query id -o tsv)
  API_SUBSCRIPTION_NAME="Echo API"

  # Get the access token
  TOKEN=$(az account get-access-token --query accessToken --output tsv)

  # get the subscription id based on the subscription display name
  API_SUBSCRIPTION_ID=$(curl -s -S -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$APIM_RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE_NAME/subscriptions?api-version=2022-08-01" | jq -r --arg API_SUBSCRIPTION_NAME "$API_SUBSCRIPTION_NAME" '.value[] | select(.properties.displayName == $API_SUBSCRIPTION_NAME) | .name' )

  # Call the Azure REST API to get subscription keys
  output=$(curl -s -S -X POST -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -H "Content-Length: 0" \
    "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$APIM_RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE_NAME/subscriptions/$API_SUBSCRIPTION_ID/listSecrets?api-version=2022-08-01")

  # Extract the subscription keys
  PRIMARY_KEY=$(echo "$output" | jq -r '.primaryKey')

  APPGATEWAYPUBLICIPADDRESS=$(az network public-ip show --resource-group "$NETWORK_RESOURCE_GROUP" --name "$APPGATEWAY_PIP" --query ipAddress -o tsv)
  testUri="curl -k -v -H 'Host: ${APPGATEWAY_FQDN}' -H 'Ocp-Apim-Subscription-Key: ${PRIMARY_KEY}' -H 'Content-Type: application/json' https://${APPGATEWAYPUBLICIPADDRESS}/echo/resource?param1=sample"
  echo "Test the deployment by running the following command: ${testUri}"
  echo -e "\n"

fi




