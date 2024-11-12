#!/bin/bash

set -e

# This script sets up the backend configuration for Terraform in Azure.
# It requires the user to be logged into Azure CLI and verifies the current subscription.
# The script accepts the following parameters:
# --resource-group or -g: The Azure resource group name for the Terraform backend.
# --storage-account or -s: The Azure storage account name for the Terraform backend.
# --container or -c: The Azure storage container name for the Terraform backend.
# --auto-confirm or -y: Automatically confirm prompts without user interaction.
# Example execution:
# ./azure-backend-sample.sh --resource-group my-resource-group --storage-account my-storage-account --container my-container --auto-confirm

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --resource-group|-g) TF_BACKEND_RESOURCE_GROUP_NAME=$2; shift 2 ;;
    --storage-account|-s) TF_BACKEND_STORAGE_ACCOUNT_NAME=$2; shift 2 ;;
    --container|-c) TF_BACKEND_CONTAINER_NAME=$2; shift 2 ;;
    --auto-confirm|-y) auto_confirm=true; shift ;;
    *) echo "Invalid argument: $1"; exit 1 ;;
  esac
done

# Validate required arguments
if [[ -z "$TF_BACKEND_RESOURCE_GROUP_NAME" || -z "$TF_BACKEND_STORAGE_ACCOUNT_NAME" || -z "$TF_BACKEND_CONTAINER_NAME" ]]; then
  echo "Error: --resource-group, --storage-account, and --container are required arguments."
  exit 1
fi


# Source .env to get Azure location
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [[ -f "$script_dir/../../.env" ]]; then
	echo "Loading .env"
	source "$script_dir/../../.env"
fi

# Ensure user is logged into Azure CLI
if ! az account show > /dev/null 2>&1; then
  echo "Please log in to Azure CLI using 'az login'."; exit 1
fi

# Display the current subscription
az account show --query "{subscriptionId:id, subscriptionName:name}" --output table

# Confirm to proceed if not auto-confirmed
if [[ $auto_confirm != true ]]; then
  read -p "Do you want to continue? (y/n): " response
  [[ $response =~ ^[Yy]$ ]] || { echo "Exiting..."; exit 1; }
fi

# Function to create resource group if it doesn't exist
create_resource_group() {
  echo "Creating resource group $TF_BACKEND_RESOURCE_GROUP_NAME..."
  az group create --name "$TF_BACKEND_RESOURCE_GROUP_NAME" --location "$AZURE_LOCATION" > /dev/null
}

# Function to create storage account if it doesn't exist
create_storage_account() {
  echo "Creating storage account and container $TF_BACKEND_STORAGE_ACCOUNT_NAME..."
  az storage account create --name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" --resource-group "$TF_BACKEND_RESOURCE_GROUP_NAME" --location "$AZURE_LOCATION" --sku Standard_LRS > /dev/null
  az storage container create --name "$TF_BACKEND_CONTAINER_NAME" --account-name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" > /dev/null
}

# Validate or create resource group
if [[ $(az group exists --name "$TF_BACKEND_RESOURCE_GROUP_NAME" --output tsv) == "false" ]]; then
  if [[ $auto_confirm == true ]]; then
    create_resource_group
  else
    read -p "Resource group not found. Create it? (y/n): " response
    [[ $response =~ ^[Yy]$ ]] && create_resource_group || { echo "Exiting..."; exit 1; }
  fi
fi


# Validate or create storage account
if ! az storage account show --name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" --resource-group "$TF_BACKEND_RESOURCE_GROUP_NAME" > /dev/null 2>&1; then
  if [[ $auto_confirm == true ]]; then
    create_storage_account
  else
    read -p "Storage account not found. Create it? (y/n): " response
    [[ $response =~ ^[Yy]$ ]] && create_storage_account || { echo "Exiting..."; exit 1; }
  fi
fi

# Validate or create container
if ! az storage container show --name "$TF_BACKEND_CONTAINER_NAME" --account-name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" > /dev/null 2>&1; then
  if [[ $auto_confirm == true ]]; then
    az storage container create --name "$TF_BACKEND_CONTAINER_NAME" --account-name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" > /dev/null
  else
    read -p "Container not found. Create it? (y/n): " response
    [[ $response =~ ^[Yy]$ ]] && az storage container create --name "$TF_BACKEND_CONTAINER_NAME" --account-name "$TF_BACKEND_STORAGE_ACCOUNT_NAME" > /dev/null || { echo "Exiting..."; exit 1; }
  fi
fi

echo "Backend resources are ready."
