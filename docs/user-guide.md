# Deploying Enterprise-Scale-APIM in your own environment 

The `Enterprise-scale-APIM` - acrhitecture solution template is intended to provision a single region premium API Management instance within an internal VNet exposed through Application Gateway for external traffic with Azure Functions as the backend (exposed through private endpoint). 

In order to Deploy an Azure Application Gateway standalone instance, which is not a part of the overall Enterprise Scale APIM solution, follow these [steps here](/deployment/bicep/gateway/readme.md)


## Pre-Requisites 
-	An Azure Subscription 
-	An active GitHub repository

## Tooling 

- [Az CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) latest version 
OR
- Azure [cloud shell](https://shell.azure.com/)


## Deployment Steps

### 1. Clone the repository to your Organisation/Repository

```
git clone https://github.com/cykreng/Enterprise-Scale-APIM.git
```
<img src= /docs/images/clone-repo.png>


### 2. Authentication from GitHub to Azure 

You can automate workflows using Azure [Login Action](https://github.com/Azure/login#github-action-for-azure-login) using a Service Principal and you can do this by running Az CLI or Azure PowerShell scripts

The Azure login action supports two different ways of authenticating with Azure :
- _Service principal with [secrets](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows#use-the-azure-login-action-with-a-service-principal-secret)_

- _OpenID Connect (OIDC) with a Azure service principal using a [Federated Identity Credential](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows#use-the-azure-login-action-with-openid-connect)_


### 3. Create a Service Principal using Az CLI commands by signing-in interactively OR using Cloud Shell

a) Interactive sign-in using [Az CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

```
az login 
```

- If the CLI can open your default browser, it will do so and load an Azure sign-in page
- Otherwise, open a browser page at https://aka.ms/devicelogin and enter the authorization code displayed in your terminal
- Sign in with your account credentials in the browser
- Run the below command if you have **multiple** subscriptions 

```
az account set --subscription <xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>
az account show
```

**OR**, if you have just have a **single** subscription, run the below command to ensure the correct subscription

```
az account show
```

b) Sign-in using Cloud Shell

<img src= /docs/images/cloud_shell.png>

```
az account show
```

<img src= /docs/images/az-account-show.jpg>

### 4. Configure Deployment Credentials 

For using credentials like a Service Principal we will need to add them as [GitHub secrets](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-encrypted-secrets-for-your-repository-and-organization-for-codespaces) in your GitHub repository

Follow the below steps to configure secrets for the authentication within the GitHub workflow :

   -	Go to your GitHub repository settings  and a ‘New repository secrets’ from Secrets menu
   -	Store the output of the below [az cli](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli#:~:text=%20Create%20an%20Azure%20service%20principal%20with%20the,role%20for%20a%20service%20principal%20is...%20See%20More.) command as a secret (e.g. AZURE_CREDENTIALS). This will be referenced back in the workflow file


```
az ad sp create-for-rbac --name "enterprise-scale-apim-app" --role contributor \
                        --scopes /subscriptions/{subscription-id} \
                        --sdk-auth
```

  - _Replace {subscription-id} with the subscription details_
    - _the above command should output a JSON object like below_

```
  {
    "clientId": "<GUID>",
    "clientSecret": "<GUID>",
    "subscriptionId": "<GUID>",
    "tenantId": "<GUID>",
    (...)
  }
```
<img src= /docs/images/secrets.png>


### 5. Run the workflow 

There is  a workflow file apim-cs.yml created under .github/workflows 

a) Generate the following secrets in your GitHub repository settings


  - `AZURE_SUBSCRIPTION` - Azure target subscription id
  - `PAT` -  Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent
  - `VM_PW` - The password to be used as the Administrator for all VMs created by this deployment


b) In order to run the deployment successfully we will need modify the **config.yml** file located in /deployment/bicep folder

|                   |          |
|:------------------|:--------:|
| `AZURE_LOCATION`  | 'Azure ergion where you want to deploy the resources| 
| `RESOURCE_NAME_PREFIX`| 'Standardized suffix text to be added to resource names' |
| `ENVIRONMENT_TAG` | 'The environment for which the deployment is being executed'  |  
| `DEPLOYMENT_NAME` | 'Unique name of the Bicep Deployment' |
| `VM_USERNAME`     | 'The user name to be used as the Administrator for all VMs created by this deployment' | 
| `ACCOUNT_NAME`    |  'The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format https://dev.azure.com/ORGNAME OR github.com/ORGUSERNAME OR none' |  
| `CICD_AGENT_TYPE` |  'The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify \'none\' if no agent needed')  |

c. Push the latest changes to your **feature** branch and create a Pull Request to **main** branch which will trigger the workflow

Alternatively, you can also trigger the workflow by going to **Actions** tab and run the `AzureBicepDeploy` workflow manually

<img src= /docs/images/manual_trigger.png>


### 6. Deployed Resources

There will be four resource groups created as follows - 

<p align="center">
   <img src= /docs/images/resource_groups.png>
</p>  

- Outputs from Backend :
<img src= /docs/images/backend.png>

- Outputs from Shared module :
<img src= /docs/images/shared.png>

- Outputs from APIM module :
<img src= /docs/images/apim.png>

- Outputs from Networking module :
<img src= /docs/images/networking.png>
