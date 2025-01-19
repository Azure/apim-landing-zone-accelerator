#!/bin/bash
set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ -f "$script_dir/../../.env" ]]; then
	echo "Loading .env"
	source "$script_dir/../../.env"
fi

if [[ ${#ENABLE_TELEMETRY} -eq 0 ]]; then
  telemetry=true
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

cat << EOF > "$script_dir/../../workload-genai/bicep/parameters.json"
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "apiManagementServiceName" :{
        "value": "${apimName}"
    },
    "resourceSuffix" :{
        "value": "${resourceSuffix}"
    },
    "apimResourceGroupName" :{
        "value": "${apimResourceGroupName}"
    },
    "apimIdentityName" :{
        "value": "${apimIdentityName}"
    },
    "vnetName" :{
        "value": "${vnetName}"
    },
    "privateEndpointSubnetid" :{
        "value": "${privateEndpointSubnetid}"
    },
    "networkingResourceGroupName" :{
        "value": "${networkingResourceGroupName}"
    },
    "enableTelemetry" :{
        "value": ${telemetry}
    }
  }
}
EOF

deployment_name="workload-genai-${RESOURCE_NAME_PREFIX}"

echo "$deployment_name"
cd "$script_dir/../../workload-genai/bicep/"
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

echo "$output" | jq "[.properties.outputs | to_entries | .[] | {key:.key, value: .value.value}] | from_entries" > "$script_dir/../../workload-genai/bicep/output.json"

apimSubscriptionKey=$(cat "$script_dir/../../workload-genai/bicep/output.json" | jq -r '.apiManagementAzureOpenAIProductSubscriptionKey')
multiTenantProduct1SubscriptionKey=$(cat "$script_dir/../../workload-genai/bicep/output.json" | jq -r '.apiManagementMultitenantProduct1SubscriptionKey')
multiTenantProduct2SubscriptionKey=$(cat "$script_dir/../../workload-genai/bicep/output.json" | jq -r '.apiManagementMultitenantProduct2SubscriptionKey')

testUri="curl -k -H 'Host: ${APPGATEWAY_FQDN}' -H 'Ocp-Apim-Subscription-Key: ${apimSubscriptionKey}' -H 'Content-Type: application/json' https://${appGatewayPublicIpAddress}/openai/deployments/aoai/chat/completions?api-version=2024-02-15-preview -d '{\"messages\": [{\"role\":\"system\",\"content\":\"You are an AI assistant that helps people find information.\"}]}'"
echo "Test the deployment by running the following command: ${testUri}"
echo -e "\n"

multiTenantProduct1TestUri="curl -k -H 'Host: ${APPGATEWAY_FQDN}' -H 'Ocp-Apim-Subscription-Key: ${multiTenantProduct1SubscriptionKey}' -H 'Content-Type: application/json' https://${appGatewayPublicIpAddress}/openai/deployments/aoai/chat/completions?api-version=2024-02-15-preview -d '{\"messages\": [{\"role\":\"system\",\"content\":\"You are an AI assistant that helps people find information.\"}]}'"
echo "Test the deployment for multi-tenant Product1 by running the following command: ${multiTenantProduct1TestUri}"
echo -e "\n"

multiTenantProduct2TestUri="curl -k -H 'Host: ${APPGATEWAY_FQDN}' -H 'Ocp-Apim-Subscription-Key: ${multiTenantProduct2SubscriptionKey}' -H 'Content-Type: application/json' https://${appGatewayPublicIpAddress}/openai/deployments/aoai/chat/completions?api-version=2024-02-15-preview -d '{\"messages\": [{\"role\":\"system\",\"content\":\"You are an AI assistant that helps people find information.\"}]}'"
echo "Test the deployment for multi-tenant Product2 by running the following command: ${multiTenantProduct2TestUri}"
echo -e "\n"