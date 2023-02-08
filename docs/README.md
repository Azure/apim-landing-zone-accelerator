# Deploying Enterprise-Scale-APIM in your own environment

The `Enterprise-scale-APIM` - architecture solution template is intended to provision a single region API Management instance within an internal VNet exposed through Application Gateway for external traffic with Azure Functions as the backend (exposed through private endpoint).

## Pre-Requisites

- An Azure Subscription
- An active GitHub repository

## Tooling

- [Az CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) latest version
OR
- Azure [cloud shell](https://shell.azure.com/)

## Deployment Steps

### 1. Fork the repository to your Organization and then clone to your repository

```Powershell
git clone https://github.com/Azure/apim-landing-zone-accelerator.git
```

![Clone Repo](/docs/images/clone-repo.png)

### 2. Authentication from GitHub to Azure

You can automate workflows using Azure [Login Action](https://github.com/Azure/login#github-action-for-azure-login) using a Service Principal and you can do this by running Az CLI or Azure PowerShell scripts.

The Azure login action supports two different ways of authenticating with Azure :

- Service principal with [secrets](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows#use-the-azure-login-action-with-a-service-principal-secret)

- OpenID Connect (OIDC) with a Azure service principal using a [Federated Identity Credential](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows#use-the-azure-login-action-with-openid-connect)

**Note** The default configuration for the APIM accelerator workflow is to use OpenID Connect.

### 3. Create a Service Principal using Az CLI commands by signing-in interactively OR using Cloud Shell

a.) Interactive sign-in using [Az CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).

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

**OR**, if you have just have a **single** subscription, run the below command to ensure the correct subscription.

```Powershell
az account show
```

b.) Sign-in using Cloud Shell.

![cloud shell](/docs/images/cloud_shell.png)

```Powershell
az account show
```

![account show](/docs/images/az-account-show.jpg)

c.) create the Azure Active Directory application.

```Powershell
az ad app create --display-name myApp
```

- This command will output JSON with an appId that is your client-id. The objectId is APPLICATION-OBJECT-ID and it will be used for creating federated credentials with Graph API calls.

d.) Create a service principal.

Replace the $appID with the appId from your JSON output. This command generates JSON output with a different objectId will be used in the next step. The new objectId is the assignee-object-id.

```Powershell
az ad sp create --id $appId
```

e.) Create a new role assignment by subscription and object. 

By default, the role assignment will be tied to your default subscription. Replace $subscriptionId with your subscription ID and $assigneeObjectId with generated assignee-object-id (the newly created service principal object id).

```Powershell
az role assignment create --role contributor --subscription $subscriptionId --assignee-object-id  $assigneeObjectId --assignee-principal-type ServicePrincipal --scope /subscriptions/$subscriptionId
```

f.) Copy the values for clientId, subscriptionId, and tenantId to use later in your GitHub Actions workflow.


### 4. Add Federated Credentials

You can add federated credentials in the Azure portal or with the Microsoft Graph REST API.

### [Azure portal](#tab/azure-portal)

1. Go to **App registrations** in the <a href="https://portal.azure.com/" target="_blank">Azure portal</a> and open the app you want to configure.
1. Within the app, go to **Certificates and secrets**.  
1. In the **Federated credentials** tab, select **Add credential**.
1. Select the credential scenario **GitHub Actions deploying Azure resources**. Generate your credential by entering your credential details.
    
|Field  |Description  |Example  |
|---------|---------|---------|
|Organization     |    Your GitHub organization name or GitHub username.     |     `contoso`    |
|Repository     |     Your GitHub Repository name.    |    `contoso-app`     |
|Entity type     |     The filter used to scope the OIDC requests from GitHub workflows. This field is used to generate the `subject` claim.   |     `Environment`, `Branch`, `Pull request`, `Tag`    |
|GitHub name     |     The name of the environment, branch, or tag.    |     `main`    |
|Name     |     Identifier for the federated credential.    |    `contoso-deploy`     |

For a more detailed overview, see [Configure an app to trust a GitHub repo](/azure/active-directory/develop/workload-identity-federation-create-trust-github).
### [Azure CLI](#tab/azure-cli)

Run the following command to [create a new federated identity credential](/graph/api/application-post-federatedidentitycredentials?view=graph-rest-beta&preserve-view=true) for your Azure Active Directory application.

* Replace `APPLICATION-OBJECT-ID` with the **objectId (generated while creating app)** for your Azure Active Directory application.
* Set a value for `CREDENTIAL-NAME` to reference later.
* Set the `subject`. The value of this is defined by GitHub depending on your workflow:
  * Jobs in your GitHub Actions environment: `repo:< Organization/Repository >:environment:< Name >`
  * For Jobs not tied to an environment, include the ref path for branch/tag based on the ref path used for triggering the workflow: `repo:< Organization/Repository >:ref:< ref path>`.  For example, `repo:n-username/ node_express:ref:refs/heads/my-branch` or `repo:n-username/ node_express:ref:refs/tags/my-tag`.
  * For workflows triggered by a pull request event: `repo:< Organization/Repository >:pull_request`.

```azurecli
az rest --method POST --uri 'https://graph.microsoft.com/beta/applications/<APPLICATION-OBJECT-ID>/federatedIdentityCredentials' --body '{"name":"<CREDENTIAL-NAME>","issuer":"https://token.actions.githubusercontent.com","subject":"repo:organization/repository:environment:Production","description":"Testing","audiences":["api://AzureADTokenExchange"]}' 
```

For a more detailed overview, see [Configure an app to trust a GitHub repo](/azure/active-directory/develop/workload-identity-federation-create-trust-github).

### [Azure PowerShell](#tab/azure-powershell) 

Run the following command to [create a new federated identity credential](/graph/api/application-post-federatedidentitycredentials?view=graph-rest-beta&preserve-view=true) for your Azure Active Directory application.

* Replace `APPLICATION-OBJECT-ID` with the **Id (generated while creating app)** for your Azure Active Directory application.
* Set a value for `CREDENTIAL-NAME` to reference later.
* Set the `subject`. The value of this is defined by GitHub depending on your workflow:
  * Jobs in your GitHub Actions environment: `repo:< Organization/Repository >:environment:< Name >`
  * For Jobs not tied to an environment, include the ref path for branch/tag based on the ref path used for triggering the workflow: `repo:< Organization/Repository >:ref:< ref path>`.  For example, `repo:n-username/ node_express:ref:refs/heads/my-branch` or `repo:n-username/ node_express:ref:refs/tags/my-tag`.
  * For workflows triggered by a pull request event: `repo:< Organization/Repository >:pull_request`.

```azurepowershell
Invoke-AzRestMethod -Method POST -Uri 'https://graph.microsoft.com/beta/applications/<APPLICATION-OBJECT-ID>/federatedIdentityCredentials' -Payload  '{"name":"<CREDENTIAL-NAME>","issuer":"https://token.actions.githubusercontent.com","subject":"repo:organization/repository:environment:Production","description":"Testing","audiences":["api://AzureADTokenExchange"]}'
```

For a more detailed overview, see [Configure an app to trust a GitHub repo](/azure/active-directory/develop/workload-identity-federation-create-trust-github).

---

### 5. Create GitHub Secrets

You need to provide your application's Client ID, Tenant ID and Subscription ID to the login action. These values can either be provided directly in the workflow or can be stored in GitHub secrets and referenced in your workflow. Saving the values as GitHub secrets is the more secure option.

Follow the below steps to configure secrets for the authentication within the GitHub workflow.

a.) Go to your GitHub repository settings and Select Security > Secrets and variables > Actions

b.) Add a new repository secrets by clicking ‘New repository secrets’ 

c.) Generate the following secrets in your GitHub repository settings

- `AZURE_OIDC_CLIENT_ID` - Service principal Application (client) id
- `AZURE_TENANT_ID` - Your Azure AD Directory (tenant) id
- `AZURE_SUBSCRIPTION_ID` - Azure target subscription id
- `AZURE_TF_STATE_RESOURCE_GROUP_NAME` - Name of the Resource Group where the Terraform remote state storage account resides
- `AZURE_TF_STATE_STORAGE_ACCOUNT_NAME` - Name of the Storage Account that contains the Terraform remote state container
- `AZURE_TF_STATE_STORAGE_CONTAINER_NAME` - Name of the Storage Account Container to initialize the Terraform remote state
- `PAT` -  Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent
- `VM_PW` - The password to be used as the Administrator for all VMs created by this deployment
- `FQDN` - Fully qualified domain name that will be used for the application gateway
- `CERTPW` - Required if *CERT_TYPE* is *custom*. The certificate should be available as appgw.pfx in the [certs](/reference-implementations/AppGW-IAPIM-Func/bicep/gateway/certs/) folder  

d.) Save each secret by selecting Add secret.


### 6. Run the workflow

There is a workflow file **es-apim.yml** created under [.github/workflows](/.github/workflows/es-apim.yml).

b) In order to run the deployment successfully we will need to modify the values in **config.yml** file located [here](/reference-implementations/AppGW-IAPIM-Func/bicep/config.yml).

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

c) Push the latest changes to your **feature** branch and create a Pull Request to **main** branch which will trigger the workflow.

Alternatively, you can also trigger the workflow by going to **Actions** tab and run the `AzureBicepDeploy` workflow manually.

![manual trigger](/docs/images/manual_trigger.png)

### 7. Deployed Resources

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

### 8. Deploy the Function and APIs

- [Import](https://learn.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?view=azure-devops) this repo to an Azure DevOps Repo
- Create two [ARM service connections](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops) each scoped to the apim resource group and the function app resource group
- Make sure that the *Default* agent pool has _Grant access to all pipelines_ selected

## Deploy the backend

- Create a pipeline using the [deploy-function.yml](/src/pipelines/deploy-function.yml) file
- Add [variables](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/variables?view=azure-devops&tabs=yaml%2Cbatch#access-variables-through-the-environment) to the pipeline 
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
