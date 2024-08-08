# Azure API Management - Secure Baseline [Bicep]

This is the Bicep-based deployment guide for [Scenario 1: Azure API Management - Secure Baseline](../README.md).

## Prerequisites

This is the starting point for the instructions on deploying this reference implementation. There is required access and tooling you'll need in order to accomplish this.

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

   Copy the `sample.env` into a new file called `.env` in the same directory.

   ```bash
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

1. Deploy the reference implementation.

   Run the following command to deploy the APIM baseline

    ```bash
    ./scripts/bicep/deploy-apim-baseline.sh
    ```

Test the echo api using the generated command from the output

## Troubleshooting

If you see the message `-bash: ./deploy-apim-baseline.sh: /bin/bash^M: bad interpreter: No such file or directory` when running the script, you can fix this by running the following command:

   ```bash
    sed -i -e 's/\r$//' deploy-apim-baseline.sh
   ```
