#!/bin/bash
set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ -f "$script_dir/../../.env" ]]; then
	echo "Loading .env"
	source "$script_dir/../../.env"
fi

if [[ -f "$script_dir/../../apim-baseline/bicep/output.json" ]]; then
	echo "Loading baseline configuration"

    while IFS='=' read -r key value; do
        export "$key=${value//\"/}"
    done < <(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' "$script_dir/../../apim-baseline/bicep/output.json")
else
    echo "ERROR: Missing baseline configuration. Run deploy-apim-baseline.sh" 1>&2
    exit 6
fi

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

if [[ ${#ENABLE_TELEMETRY} -eq 0 ]]; then
  telemetry=true
fi

cat << EOF > "$script_dir/../../workload-functions/bicep/parameters.json"
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "resourceSuffix" :{
        "value": "${resourceSuffix}"
    },
    "networkingResourceGroupName" :{
        "value": "${networkingResourceGroupName}"
    },
    "apimResourceGroupName" :{
        "value": "${apimResourceGroupName}"
    },
    "apimName" :{
        "value": "${apimName}"
    },
    "vnetName" :{
        "value": "${vnetName}"
    },
    "deploymentIdentityName" :{
        "value": "${deploymentIdentityName}"
    },
    "deploymentSubnetId" :{
        "value": "${deploymentSubnetId}"
    },
    "deploymentStorageName" :{
        "value": "${deploymentStorageName}"
    },
    "privateEndpointSubnetid" :{
        "value": "${privateEndpointSubnetid}"
    },
    "sharedResourceGroupName" :{
        "value": "${sharedResourceGroupName}"
    },
    "enableTelemetry" :{
        "value": ${telemetry}
    }
  }
}
EOF

deployment_name="workload-functions-${RESOURCE_NAME_PREFIX}"

echo "$deployment_name"
cd "$script_dir/../../workload-functions/bicep/"
echo "=="
echo "== Starting bicep deployment ${deployment_name}"
echo "=="
output=$(az deployment sub create \
  --template-file main.bicep \
  --name "$deployment_name" \
  --parameters parameters.json \
  --location "$AZURE_LOCATION" \
  --output json)

echo "== Completed bicep deployment ${deployment_name}"

echo "$output" | jq "[.properties.outputs | to_entries | .[] | {key:.key, value: .value.value}] | from_entries" > "$script_dir/../../workload-functions/bicep/output.json"

APPGATEWAY_FQDN="${APPGATEWAY_FQDN%$'\r'}"
testUri="curl -k -H 'Host: ${APPGATEWAY_FQDN}' -H 'Ocp-Apim-Subscription-Key: ${apimStarterSubscriptionKey}' https://${appGatewayPublicIpAddress}/hello?name=world"
echo "Test the deployment by running the following command: ${testUri}"
echo -e "\n"
