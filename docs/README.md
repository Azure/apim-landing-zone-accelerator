# Deploying Enterprise-Scale-APIM in your own environment

The `Enterprise-scale-APIM` - architecture solution template is intended to provision a single region premium API Management instance within an internal VNet exposed through Application Gateway for external traffic with Azure Functions as the backend (exposed through private endpoint)

## Pre-Requisites

- An Azure Subscription
- An active GitHub repository

## Tooling

- [Az CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) latest version
OR
- Azure [cloud shell](https://shell.azure.com/)

## Deployment Steps

### 1. Fork the repository to your Organization and then clone to your repository. 

```Powershell
git clone https://github.com/Azure/apim-landing-zone-accelerator.git
```

![Clone Repo](/docs/images/clone-repo.png)

### 2. Authentication from GitHub to Azure

You can automate workflows using Azure [Login Action](https://github.com/Azure/login#github-action-for-azure-login) using a Service Principal and you can do this by running Az CLI or Azure PowerShell scripts

The Azure login action supports two different ways of authenticating with Azure :

- Service principal with [secrets](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows#use-the-azure-login-action-with-a-service-principal-secret)

- OpenID Connect (OIDC) with a Azure service principal using a [Federated Identity Credential](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows#use-the-azure-login-action-with-openid-connect)

### 3. Create a Service Principal using Az CLI commands by signing-in interactively OR using Cloud Shell

a) Interactive sign-in using [Az CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

```Powershell
az login
```

- If the CLI can open your default browser, it will do so and load an Azure sign-in page
- Otherwise, open a browser page at <https://aka.ms/devicelogin> and enter the authorization code displayed in your terminal
- Sign in with your account credentials in the browser
- Run the below command if you have **multiple** subscriptions

```Powershell
az account set --subscription <xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>
az account show
```

**OR**, if you have just have a **single** subscription, run the below command to ensure the correct subscription

```Powershell
az account show
```

b) Sign-in using Cloud Shell

![cloud shell](/docs/images/cloud_shell.png)

```Powershell
az account show
```

![account show](/docs/images/az-account-show.jpg)

### 4. Configure Deployment Credentials

For using credentials like a Service Principal we will need to add them as [GitHub secrets](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-encrypted-secrets-for-your-repository-and-organization-for-codespaces) in your GitHub repository

#### Follow the below steps to configure secrets for the authentication within the GitHub workflow :

- Go to your GitHub repository settings and add a new Actions secrets by clicking ‘New repository secrets’ from the Secrets menu
- Store the output of the below [az cli](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli#:~:text=%20Create%20an%20Azure%20service%20principal%20with%20the,role%20for%20a%20service%20principal%20is...%20See%20More.) command as a secret (e.g. AZURE_CREDENTIALS). This will be referenced back in the workflow file


```PowerShell
# Replace {subscription-id} with your subscription details
az ad sp create-for-rbac --name "enterprise-scale-apim-app" --role contributor \
                        --scopes /subscriptions/{subscription-id} \
                        --sdk-auth
```

- This command should output a json object, store that output as a secret (e.g. AZURE_CREDENTIALS).  This will be referenced back in the workflow file.
- _Sample JSON output to be stored as a secret in Github_

```Powershell
  {
    "clientId": "<GUID>",
    "clientSecret": "<GUID>",
    "subscriptionId": "<GUID>",
    "tenantId": "<GUID>",
    (...)
  }
```

- Go to your GitHub repository settings and add a new Actions secrets by clicking ‘New repository secrets’ from the Secrets menu
![secrets](/docs/images/secrets.png)

### 5. Run the workflow

There is a workflow file **es-apim.yml** created under [.github/workflows](/.github/workflows/es-apim.yml)

a) Generate the following secrets in your GitHub repository settings

- `AZURE_CREDENTIALS` - Service principal credentials used to access Azure resources
- `AZURE_SUBSCRIPTION` - Azure target subscription id
- `PAT` -  Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent
- `VM_PW` - The password to be used as the Administrator for all VMs created by this deployment
- `FQDN` - Fully qualified domain name that will be used for the application gateway
- `CERTPW` - Required if *CERT_TYPE* is *custom*. The certificate should be available as appgw.pfx in the [certs](/reference-implementations/AppGW-IAPIM-Func/bicep/gateway/certs/) folder  

b) In order to run the deployment successfully we will need to modify the values in **config.yml** file located [here](/reference-implementations/AppGW-IAPIM-Func/bicep/config.yml)

|                   |          |
|:------------------|:--------:|
| `AZURE_LOCATION`  | 'Azure region where you want to deploy the resources|
| `RESOURCE_NAME_PREFIX`| 'Standardized suffix text to be added to resource names' |
| `ENVIRONMENT_TAG` | 'The environment for which the deployment is being executed'  |
| `DEPLOYMENT_NAME` | 'Unique name of the Bicep Deployment' |
| `VM_USERNAME`     | 'The user name to be used as the Administrator for all VMs created by this deployment' |
| `ACCOUNT_NAME`    |  'The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format <https://dev.azure.com/ORGNAME> OR github.com/ORGUSERNAME OR none' |
| `CICD_AGENT_TYPE` |  'The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify \'none\' if no agent needed')  |
| `CERT_TYPE`  | 'The type of certificate utilized in the deployment process. You can enter selfsigned to have utilize a key vault aut generated certificate or custom to access your organizations pfx file.' |

c) Push the latest changes to your **feature** branch and create a Pull Request to **main** branch which will trigger the workflow

Alternatively, you can also trigger the workflow by going to **Actions** tab and run the `AzureBicepDeploy` workflow manually

![manual trigger](/docs/images/manual_trigger.png)

### 6. Deployed Resources

#### There will be four resource groups created as follows

![resource group](/docs/images/resource_groups.png)

#### Outputs from Backend

![backend module](/docs/images/backend.png)

#### Outputs from Shared module

![shared module](/docs/images/shared.png)

#### Outputs from APIM module

![apim module](/docs/images/apim.png)

#### Outputs from Networking module

![networking module](/docs/images/networking.png)

### 7. Deploy the Function and APIs

- [Import](https://docs.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?view=azure-devops) this repo to an Azure DevOps Repo
- Create two [ARM service connections](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops) each scoped to the apim resource group and the fucntion app resource group
- Make sure that the *Default* agent pool has _Grant access to all pipelines_ selected

## Deploy the backend

- Create a pipeline using the [deploy-function.yml](/src/pipelines/deploy-function.yml) file
- Add [variables](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/variables?view=azure-devops&tabs=yaml%2Cbatch#access-variables-through-the-environment) to the pipeline 
  - armServiceConnection - the service connection scoped to the backend resource group
  - functionAppName - name of the function app in the backend resource group
  - poolName
- Run the pipeline

_note: pool name is Default if using the construction set scripts_

## Deploy the APIs

### Generator pipeline

- Create a pipeline using the [apim-generator.yml](/src/pipelines/apim-generator.yml) file. This generates the ARM templates from open api specification
- Add variables for
  - poolName
- Run the pipeline

_note:pool name is Default if using the construction set scripts_

### Collector pipeline

- Create a pipeline using the [apim-collector.yml](/src/pipelines/apim-collector.yml) file. This collects the artifacts from the generator and deploys.
- Add variables fro
  - poolName
  - apimResourceGroup
  - apimName
  - todoServiceUrl - url of the function app
  - armServiceConnection - the service connection scoped to the apim resource group
  - teamOneBuildPipelineId - Id of the generator pipeline which can be seen in the url
- Run the pipeline
