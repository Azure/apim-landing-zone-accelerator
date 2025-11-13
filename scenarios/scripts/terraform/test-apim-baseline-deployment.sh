#!/bin/bash

set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
env_file="./.env"




if [[ -f "$env_file" ]]; then
	echo "Found .env, sourcing it..."
  cat "$env_file"
	source "$env_file"
else
  echo "###########################"
  echo "Error: .env file not found in the current directory."
  echo "       a sample is available at ./sample.env"
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
  echo -e "\nRANDOM_IDENTIFIER='$random_string'" >> "$env_file"
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



# Get the current subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)


# Testing the deployment
echo "Validating deployment..."
  APIM_SERVICE_NAME="apim-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
  APIM_RESOURCE_GROUP="rg-apim-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
  NETWORK_RESOURCE_GROUP="rg-networking-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"
  APPGATEWAY_PIP="pip-appgw-${RESOURCE_NAME_PREFIX}-${ENVIRONMENT_TAG}-${AZURE_LOCATION}-${RANDOM_IDENTIFIER}"

  SUBSCRIPTION_ID=$(az account show --query id -o tsv)
  API_SUBSCRIPTION_NAME="Echo API"

  # Get the access token
  echo "Obtaining Access Token..."
  TOKEN=$(az account get-access-token --query accessToken --output tsv)

  # get the subscription id based on the subscription display name
  echo "Getting API Management Subscription info ... [1/3]"
  API_MANAGEMENT_INFO=$(curl -s -S -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$APIM_RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE_NAME/subscriptions?api-version=2022-08-01")
  
  echo "Getting API Management Subscription info ... [2/3]"
  API_SUBSCRIPTION_ID=$(echo $API_MANAGEMENT_INFO | jq -r --arg API_SUBSCRIPTION_NAME "$API_SUBSCRIPTION_NAME" '.value[] | select(.properties.displayName == $API_SUBSCRIPTION_NAME) | .name' )
  echo "Getting API Management Subscription info ... [3/3]"
  # Call the Azure REST API to get subscription keys
  output=$(curl -s -S -X POST -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -H "Content-Length: 0" \
    "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$APIM_RESOURCE_GROUP/providers/Microsoft.ApiManagement/service/$APIM_SERVICE_NAME/subscriptions/$API_SUBSCRIPTION_ID/listSecrets?api-version=2022-08-01")

  # Extract the subscription keys
  PRIMARY_KEY=$(echo "$output" | jq -r '.primaryKey')


  if [[ "$MULTI_REGION" == "true" ]]; then
    
    APPGWNAME_DASHES="${APPGATEWAY_FQDN//./-}"
    TRAFFIC_MANAGER_FQDN="${APPGWNAME_DASHES}.trafficmanager.net"
    #testUri="curl -k -v https://${TRAFFIC_MANAGER_FQDN}/status-0123456789abcdef"
    testUri="curl -k -v -H 'Ocp-Apim-Subscription-Key: ${PRIMARY_KEY}' -H 'Content-Type: application/json' https://${TRAFFIC_MANAGER_FQDN}/echo/resource?param1=sample"
    echo "Testing against ${TRAFFIC_MANAGER_FQDN}"
    eval ${testUri}

    echo "Test the deployment by running the following command: ${testUri}"
    echo -e "\n"

  else
    
    APPGATEWAYPUBLICIPADDRESS=$(az network public-ip show --resource-group "$NETWORK_RESOURCE_GROUP" --name "$APPGATEWAY_PIP" --query ipAddress -o tsv)
    testUri="curl -k -v -H 'Host: ${APPGATEWAY_FQDN}' -H 'Ocp-Apim-Subscription-Key: ${PRIMARY_KEY}' -H 'Content-Type: application/json' https://${APPGATEWAYPUBLICIPADDRESS}/echo/resource?param1=sample"
    echo "Testing against ${APPGATEWAY_FQDN}"
    eval ${testUri}

    echo "Test the deployment by running the following command: ${testUri}"
    echo -e "\n"

  fi




