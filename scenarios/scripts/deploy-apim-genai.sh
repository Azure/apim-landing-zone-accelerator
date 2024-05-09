#!/bin/bash
set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ -f "$script_dir/../.env" ]]; then
	echo "Loading .env"
	source "$script_dir/../.env"
fi

cd "$script_dir/../infra/apim-genai"

if [[ "${USE_SIMULATOR}" != "true" ]]; then
  if [[ ${#PTU_DEPLOYMENT_1_BASE_URL} -eq 0 ]]; then
    echo 'ERROR: Missing environment variable PTU_DEPLOYMENT_1_BASE_URL' 1>&2
    exit 6
  else
    PTU_DEPLOYMENT_1_BASE_URL="${PTU_DEPLOYMENT_1_BASE_URL%$'\r'}"
  fi

  if [[ ${#PAYG_DEPLOYMENT_1_BASE_URL} -eq 0 ]]; then
    echo 'ERROR: Missing environment variable PAYG_DEPLOYMENT_1_BASE_URL' 1>&2
    exit 6
  else
    PAYG_DEPLOYMENT_1_BASE_URL="${PAYG_DEPLOYMENT_1_BASE_URL%$'\r'}"  
  fi

  if [[ ${#PAYG_DEPLOYMENT_2_BASE_URL} -eq 0 ]]; then
    echo 'ERROR: Missing environment variable PAYG_DEPLOYMENT_2_BASE_URL' 1>&2
    exit 6
  else
    PAYG_DEPLOYMENT_2_BASE_URL="${PAYG_DEPLOYMENT_2_BASE_URL%$'\r'}"  
  fi
fi

#
# This script uses a number of files to store generated keys and outputs from the deployment:
# - generated-keys.json: stores generated keys (e.g. API Key for the API simulator)
# - output-simulator-base.json: stores the output from the base simulator deployment (e.g. container registry details)
# - output-simulators.json: stores the output from the simulator instances deployment (e.g. simulator endpoints)
# - output.json: stores the output from the main deployment (e.g. APIM endpoints)
#

output_generated_keys="$script_dir/../infra/apim-genai/generated-keys.json"
output_base="$script_dir/../apim-baseline/output.json"

# Ensure output-keys.json exists and add empty JSON object if not
if [[ ! -f "$output_generated_keys" ]]; then
  echo "{}" > "$output_generated_keys"
fi

RESOURCE_GROUP_NAME=$(jq -r '.apimResourceGroupName // ""' < "$output_base")
API_MANAGEMENT_SERVICE_NAME=$(jq -r '.apimName // ""' < "$output_base")
  
#
# Ensure that the base urls end with /openai (TODO - do we want to enforce this here? or in the APIM config for the back-ends?)
#
if [[ "${PTU_DEPLOYMENT_1_BASE_URL: -7}" != "/openai" ]]; then
    PTU_DEPLOYMENT_1_BASE_URL="${PTU_DEPLOYMENT_1_BASE_URL}/openai"
fi
if [[ "${PAYG_DEPLOYMENT_1_BASE_URL: -7}" != "/openai" ]]; then
    PAYG_DEPLOYMENT_1_BASE_URL="${PAYG_DEPLOYMENT_1_BASE_URL}/openai"
fi
if [[ "${PAYG_DEPLOYMENT_2_BASE_URL: -7}" != "/openai" ]]; then
    PAYG_DEPLOYMENT_2_BASE_URL="${PAYG_DEPLOYMENT_2_BASE_URL}/openai"
fi


#
# Deploy APIM policies etc
#
cat << EOF > "$script_dir/../infra/apim-genai/azuredeploy.parameters.json"
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "workloadName" :{ 
        "value": "${RESOURCE_NAME_PREFIX}"
    },
    "environment" :{ 
        "value": "${ENVIRONMENT_TAG}"
    },
    "apiManagementServiceName" :{ 
        "value": "${API_MANAGEMENT_SERVICE_NAME}"
    },
    "ptuDeploymentOneBaseUrl": {
        "value": "${PTU_DEPLOYMENT_1_BASE_URL}"
    },
    "ptuDeploymentOneApiKey": {
        "value": "${SIMULATOR_API_KEY}"
    },
    "payAsYouGoDeploymentOneBaseUrl": {
        "value": "${PAYG_DEPLOYMENT_1_BASE_URL}"
    },
    "payAsYouGoDeploymentOneApiKey": {
        "value": "${SIMULATOR_API_KEY}"
    },
    "payAsYouGoDeploymentTwoBaseUrl": {
        "value": "${PAYG_DEPLOYMENT_2_BASE_URL}"
    },
    "payAsYouGoDeploymentTwoApiKey": {
        "value": "${SIMULATOR_API_KEY}"
    }
  }
}
EOF

deployment_name="genai-${RESOURCE_NAME_PREFIX}"

echo "$deployment_name"
echo "=="
echo "== Starting bicep deployment ${deployment_name}"
echo "=="
output=$(az deployment group create \
  --template-file main.bicep \
  --name "$deployment_name" \
  --parameters azuredeploy.parameters.json \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --output json)
  
echo "== Completed bicep deployment ${deployment_name}"

echo "$output" | jq "[.properties.outputs | to_entries | .[] | {key:.key, value: .value.value}] | from_entries" > "$script_dir/../infra/apim-genai/output.json"

echo -e "\n"