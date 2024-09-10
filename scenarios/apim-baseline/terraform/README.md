# Azure API Management - Secure Baseline [Terraform]

This is the Terraform-based deployment guide for [Scenario 1: Azure API Management - Secure Baseline](../README.md).

## Prerequisites

This is the starting point for the instructions on deploying this reference implementation. There is the required access and tooling you'll need in order to accomplish this.

- An Azure subscription
- The following resource providers [registered](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider):
  - `Microsoft.ApiManagement`
  - `Microsoft.Network`
  - `Microsoft.KeyVault`
- The user or service principal initiating the deployment process must have the [owner role](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#owner) at the subscription level to have the ability to create resource groups and to delegate access to others (Azure Managed Identities created from the IaC deployment).
- Access to Bash command line to run the deployment script.
- Latest [Azure CLI installed](https://learn.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest) (must be at least 2.40), or you can perform this from Azure Cloud Shell by clicking below.

  [![Launch Azure Cloud Shell](https://learn.microsoft.com/azure/includes/media/cloud-shell-try-it/launchcloudshell.png)](https://shell.azure.com)
- JQ command line JSON processor installed

   ```bash
   sudo apt-get install jq
   ```
- Terraform installed. You can download the latest version from the [Terraform website](https://www.terraform.io/downloads.html). However, if using the dev container, this will not need to be downloaded and installed separately. 

## Steps

1. Clone/download this repo locally, or even better fork this repository.

   ```bash
   git clone https://github.com/Azure/apim-landing-zone-accelerator.git
   cd apim-landing-zone-accelerator/scenarios/scripts
   ```

1. Log into Azure from the AZ CLI and select your subscription.

   ```bash
   az login
   ```

1. Review and update deployment parameters.

   Copy the `sample.env` into a new file called `.env` in the same directory. The main difference with the Bicep version is the need for a backend when deploying Terraform templates.

   The [**.env**](../../.env) parameter file is where you can customize your deployment. The defaults are a suitable starting point, but feel free to adjust any to fit your requirements.

   **Deployment parameters**

    | Name  | Description | Default | Example(s) |
    | :---- | :---------- | :------ | :--------- |
    | `AZURE_LOCATION` | The Azure location to deploy to. | **eastus** | **westus** |
    | `RESOURCE_NAME_PREFIX` | A suffix for naming. | **apimdemo** | **appname** |
    | `ENVIRONMENT_TAG` | A tag that will be included in the naming. | **dev** | **stage** |
    | `APPGATEWAY_FQDN` | The Azure location to deploy to. | **apim.example.com** | **my.org.com** |
    | `CERT_TYPE` | selfsigned will create a self-signed certificate for the APPGATEWAY_FQDN. custom will use an existing certificate in pfx format that needs to be available in the [certs](../../certs) folder and named appgw.pfx | **selfsigned** | **custom** |
    | `CERT_PWD` | The password for the pfx certificate. Only required if CERT_TYPE is custom. | **N/A** | **password123** |
    | `RANDOM_IDENTIFIER` | Optional 3 character random string to ensure deployments are unique. Automatically assigned if not provided | **abc** | **pqr** |

1. For terraform to work, you'll need to setup the [tf backend](https://developer.hashicorp.com/terraform/language/settings/backends/configuration). As part of the repository we provide a `azure-backend-sample.sh` script. This script will create a storage account and a container to store the terraform state. You can run the script with the following command:

    ```bash
    ./azure-backend-sample.sh \
         --resource-group my-resource-group \
         --storage-account mystorageaccount \
         --container my-container
    ```

1. After setting up your backend, create a `${ENVIRONMENT_TAG}-backend.hcl` file in the same directory as your `.env`. Don't include the key value, as it is hardcoded in the script. If you are using the sample script (TF Backend in Azure), the file should look like the `sample.backend.hcl` file. So if you are going to use an Azure Backend for your Terraform provider and your ENVIRONMENT_TAG is `dev`, you should have a `dev-backend.hcl` file in the same directory as your `.env` file that looks like this:

   ```hcl
   resource_group_name  = "my-resource-group"
   storage_account_name = "mystorageaccount"
   container_name       = "my-container"
   ```


1. Deploy the reference implementation.

   Run the following command to deploy the APIM baseline

    ```bash
    ./scripts/terraform/deploy-apim-baseline.sh
    ```

During script execution, you will encounter prompts and will need to respond with a 'y' to continue.

Test the echo api using the generated command from the output.

## Troubleshooting

If you see the message `-bash: ./deploy-apim-baseline.sh: /bin/bash^M: bad interpreter: No such file or directory` when running the script, you can fix this by running the following command:

   ```bash
    sed -i -e 's/\r$//' deploy-apim-baseline.sh
   ```
