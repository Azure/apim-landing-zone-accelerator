# Azure API Management - Secure Baseline [Terraform]
- Single Region Deployment
- Optional Multi-Region High Availability
- Optional Zone Redundancy



This is the Terraform-based deployment guide for [Scenario 1: Azure API Management - Secure Baseline](../README.md).

## Prerequisites

This is the starting point for the instructions on deploying this reference implementation. There is the required access and tooling you'll need in order to accomplish this.

- An Azure subscription
- The following resource providers [registered](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider):
  - `Microsoft.ApiManagement`
  - `Microsoft.Network`
  - `Microsoft.KeyVault`
- The user or service principal initiating the deployment process must either the [owner role](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#owner) or the permissions below for a least privilege setup:

    | Role  | Level | Why |
    | :---- | :---------- | :------ |
    | Contributor | Subscription | The plan needs the ability to create resource groups |
    | User Access Administrator | Subscription | The plan delegate access to Azure Managed Identities created by the deployment. The UAA role can be scoped to just "Storage File Data Privileged Contributor" for security hardening.  | 





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
   cd apim-landing-zone-accelerator/scenarios/scripts/terraform
   ```

2. Log into Azure from the AZ CLI and select your subscription.

   ```bash
   az login
   ```

3. Review and update deployment parameters.

   Copy the [`sample.env`](../../scripts/terraform/sample.env) into a new file called `.env` in the same directory. The main difference with the Bicep version is the need for a backend when deploying Terraform templates.
   ```bash
   cp sample.env .env
   ```

   The **.env** parameter file is where you can customize your deployment. The defaults are a suitable starting point, but feel free to adjust any to fit your requirements.

   **Deployment parameters**

    | Name  | Description | Default | Example(s) |
    | :---- | :---------- | :------ | :--------- |
    | `AZURE_LOCATION` | The Azure location to deploy to. | **eastus2** | **eastus2** |
    | `MULT_REGION`| Should this deployment extend to a secondary location? |  **false**          | **true** |
    | `AZURE_LOCATION2`| The Azure secondary location to deploy to? |  **centralus**          | **centralus** |
    | `ZONE_REDUNDANT` | Should the deployment be zone redundant. | **false** | **true** |
    | `RESOURCE_NAME_PREFIX` | A suffix for naming. | **apimdemo** | **appname** |
    | `ENVIRONMENT_TAG` | A tag that will be included in the naming. | **dev** | **stage** |
    | `APPGATEWAY_FQDN` | The Azure location to deploy to. | **apim.example.com** | **my.org.com** |
    | `CERT_TYPE` | selfsigned will create a self-signed certificate for the APPGATEWAY_FQDN. custom will use an existing certificate in pfx format that needs to be available in the [certs](../../certs) folder and named appgw.pfx | **selfsigned** | **custom** |
    | `CERT_PWD` | The password for the pfx certificate. Only required if CERT_TYPE is custom. | **N/A** | **password123** |
    | `RANDOM_IDENTIFIER` | Optional 3 character random string to ensure deployments are unique. Automatically assigned if not provided | **abc** | **pqr** |

   ### examples `.env` file
   - Single region, Single Zone deployment with Developer SKU
   ```bash
      AZURE_LOCATION='eastus2'
      RESOURCE_NAME_PREFIX='lzv01'
      ENVIRONMENT_TAG='dev'
      APPGATEWAY_FQDN='apim.example.com'
      CERT_TYPE='selfsigned'
      ZONE_REDUNDANT='false'
      MULTI_REGION='false'
      AZURE_LOCATION2=''
   ```
   - Single region and Zone redundant deployment with Premium SKU
   ```bash
      AZURE_LOCATION='eastus2'
      RESOURCE_NAME_PREFIX='lzv01'
      ENVIRONMENT_TAG='dev'
      APPGATEWAY_FQDN='apim.example.com'
      CERT_TYPE='selfsigned'
      ZONE_REDUNDANT='true'
      MULTI_REGION='false'
   ```
   - Multi-region and Zone Redundant deployment with Premium SKU
   ```bash
      AZURE_LOCATION='eastus2'
      RESOURCE_NAME_PREFIX='lzv01'
      ENVIRONMENT_TAG='dev'
      APPGATEWAY_FQDN='apim.example.com'
      CERT_TYPE='selfsigned'
      ZONE_REDUNDANT='true'
      MULTI_REGION='true'
      AZURE_LOCATION2='centralus'
   ```


4. For terraform, you have the option to setup a backend [tf backend](https://developer.hashicorp.com/terraform/language/settings/backends/configuration). As part of the repository we provide a `azure-backend-sample.sh` script. This script will create a storage account and a container to store the terraform state. You can run the script with the following command:

    ```bash
    ./azure-backend-sample.sh \
         --resource-group my-resource-group \
         --storage-account mystorageaccount \
         --container my-container 
    ```

5. An `${ENVIRONMENT_TAG}-backend.hcl` file will be created automatically in the same directory as your `.env`. The file looks like this:

   ```hcl
   resource_group_name  = "my-resource-group"
   storage_account_name = "mystorageaccount"
   container_name       = "my-container"
   ```

   Note: When using an AZURERM Backend and if your deployment is using a service principal vs a user account to login, make sure to also follow the terraform guidance here:
   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform



6. Deploy the reference implementation.

   Run the following command to deploy the APIM baseline

    ```bash
    ./deploy-apim-baseline.sh
    ```

During script execution, you will encounter prompts and will need to respond with a 'y' to continue.

Test the echo api using the generated command from the output.

## Troubleshooting

If you see the message `-bash: ./deploy-apim-baseline.sh: /bin/bash^M: bad interpreter: No such file or directory` when running the script, you can fix this by running the following command:

   ```bash
    sed -i -e 's/\r$//' deploy-apim-baseline.sh
   ```
