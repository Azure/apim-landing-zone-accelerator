# API Management - Terraform Implementation Guide

## Table of Contents

- [Overview](#overview)
  - [Folder Structure](#folder-structure)
    - [Deployment Files](#deployment-files)
    - [Modules](#modules)
  - [Naming convention](#naming-convention)
- [:rocket: Getting started](#-rocket--getting-started)
  - [Setting up your environment](#setting-up-your-environment)
    - [Configure Terraform](#configure-terraform)
    - [Configure Remote Storage Account](#configure-remote-storage-account)
  - [Deploy the API Management Landing Zone](#deploy-the-api-management-landing-zone)
    - [Configure Terraform Remote State](#configure-terraform-remote-state)
    - [Provide Parameters Required for Deployment](#provide-parameters-required-for-deployment)
    - [Deploy](#deploy)

## Pre-requisites

1. [Terraform](#configure-terraform)
1. [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
1. Azure Subscription

## Overview

### Folder Structure

```bash
.
└──reference-implementations/AppGW-IAPIM-Func/terraform
    ├── modules
    │   ├── backend
    │   ├── shared
    │   ├── networking
    │   ├── apim
    │   └── gateway
    ├── provider.tf
    ├── main.tf
    ├── variables.tf
    └── outputs.tf

```

#### Deployment Files

- [`module.md`](./module.md) - Terraform implementation summary document generated via [pre-commit hooks](../../../.pre-commit-config.yaml).
- [`main.tf`](./main.tf) - Main deployment file, specifies module references, dependency chains, and manages input arguments.
- [`provider.tf`](./provider.tf) - Configure remote backend state storage and required provider versions.
- [`variables.tf`](./variables.tf) - Input variable declarations with descriptions.

#### Modules

Each module has a `module.md` document that aims to give a quick overview of the module arguments, and terraform resources that are being leveraged when the module is being deployed.
This document is automatically generated based upon the configuration found in the `*.tf` files in the module directory.

- [`apim`](./modules/apim/module.md) - Deploys API Management and monitoring resources, as well as the resource group
- [`backend`](./modules/backend/module.md) - Deploys the backend resources for the application (Function, Storage Account, App Service Plan)
- [`gateway`](./modules/gateway/module.md) - Deploys the application gateway with its associated dependencies.
- [`networking`](./modules/networking/module.md) - Deploys networking configuration for the APIM deployment.
- [`service-suffix`](./modules/service-suffix/module.md) - Constructs suffix to support naming standards (see [Naming Convention](#naming-convention))
- [`shared`](./modules/shared/module.md) - Deploys Private DNS with a Windows VM

### Naming convention

This project leverages the [`service-suffix`](./modules/service-suffix/) module to standardize and construct the `resource_suffix` to enforce naming standards across deployments.

`resource_suffix` is constructed based on terraform input variables as follows:

```bash
resource_suffix = ${workloadName}-${environment}-${location}-${resource_suffix}
```

Examples:

```bash
ResourceGroupName = rg-${module}-${resource_suffix} [e.g. rg-shared-apidemo-dev-eastus-001]
APIMName = apim-${resource_suffix} [e.g. apim-apidemo-dev-eastus-001]
AppInsightsName = appi-${resource_suffix} [e.g. appi-apidemo-dev-eastus-001]
```

## :rocket: Getting started

### Setting up your environment

#### Configure Terraform

If you haven't already done so, configure Terraform using one of the following options:

- [Configure Terraform in Azure Cloud Shell with Bash](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-bash)
- [Configure Terraform in Azure Cloud Shell with PowerShell](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-powershell)
- [Configure Terraform in Windows with Bash](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash)
- [Configure Terraform in Windows with PowerShell](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-powershell)

#### Configure Remote Storage Account

Before you use Azure Storage as a backend, you must create a storage account.
Run the following commands or configuration to create an Azure storage account and container:

Powershell

```powershell
$RESOURCE_GROUP_NAME='tfstate'
$STORAGE_ACCOUNT_NAME="tfstate$(Get-Random)"
$CONTAINER_NAME='tfstate'

# Create resource group
New-AzResourceGroup -Name $RESOURCE_GROUP_NAME -Location eastus

# Create storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME -Name $STORAGE_ACCOUNT_NAME -SkuName Standard_LRS -Location eastus -AllowBlobPublicAccess $true

# Create blob container
New-AzStorageContainer -Name $CONTAINER_NAME -Context $storageAccount.context -Permission blob
```

Alternatively, the [Terraform Dependencies](../../../.github/workflows/terraform-dependencies.yml) actions workflow can provision the Terraform remote state storage account and container. Customize the deployment through setting the following GITHUB_SECRETS for your own repository's action workflows:
- `AZURE_TF_STATE_RESOURCE_GROUP_NAME` - Name of the Resource Group to create to store the Terraform remote state backend resources within.
- `AZURE_TF_STATE_STORAGE_ACCOUNT_NAME` - Name of the Storage Account for the Terraform remote state.
- `AZURE_TF_STATE_STORAGE_CONTAINER_NAME` - Name of the Storage Account Container to store the Terraform state files.

For additional reading around remote state:

- [MS Doc: Store Terraform state in Azure Storage](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli)
- [TF Doc: AzureRM Provider Configuration Documentation](https://www.terraform.io/language/settings/backends/azurerm)
- [GitHub Doc: GitHub Actions Secrets](https://learn.github.com/en/github-ae@latest/rest/actions/secrets)

### Deploy the API Management Landing Zone

#### Configure Terraform Remote State

To configure your Terraform deployment to use the newly provisioned storage account and container, edit the [`./provider.tf`](./provider.tf) file at lines 3-7 as below:

```hcl
  backend "azurerm" {
    storage_account_name = "apimlztfbackend "
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
```

- `storage_account_name`: Name of the Azure Storage Account to be used to hold remote state.
- `container_name`: Name of the Azure Storage Account Blob Container to store and retrieve remote state.
- `key`: Path and filename for the remote state file to be placed in the Storage Account Container. If the state file does not exist in this path, Terraform will automatically generate one for you.

#### Provide Parameters Required for Deployment

As you configured the backend remote state with your live Azure infrastructure resource values, you must also provide them for your deployment.

1. Review the available variables with their descriptions and default values in the [variables.tf](./variables.tf) file.
2. Provide any custom values to the defined variables by creating a `terraform.tfvars` file in this directory (`reference-implementations/AppGW-IAPIM-Func/terraform/terraform.tfvars`)
    - [TF Docs: Variable Definitions (.tfvars) Files](https://www.terraform.io/language/values/variables#variable-definitions-tfvars-files)

#### Deploy

1. Navigate to the Terraform directory `reference-implementations/AppGW-IAPIM-Func/terraform`
1. Initialize Terraform to install `required_providers` specified within the `backend.tf` and to initialize the backend remote state
    - to run locally without the remote state, comment out the `backend "azurerm"` block in `backend.tf` (lines 8-13)

    ```bash
    terraform init
    ```

1. See the planned Terraform deployment and verify resource values

    ```bash
    terraform plan
    ```

1. Deploy

    ```bash
    terraform apply
    ```
