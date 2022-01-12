# Deploying Enterprise-Scale-APIM in your own environment 

The `Enterprise-scale-APIM` - acrhitecture solution template is intended to provision an APIM instance and other core managed services

In order to Deploy an Azure Application Gateway standalone, which is not a part of the overall Enterprise Scale APIM solution, follow these [steps here](/deployment/bicep/gateway/readme.md)


## Pre-Requisites 
-	An Azure Subscription 
-	An active GitHub repository

## Optional Pre-requisites

**TBC**

## Tooling 

- Az cli latest version 

## What will be deployed

**TBC**

## Deployment Steps

### 1. Clone the repository to your Organisation/Repository

```
git clone https://github.com/cykreng/Enterprise-Scale-APIM.git
```
<img src= /docs/images/clone-repo.png width=800 height=400>


### 2. Authentication from GitHub to Azure 

You can automate workflows using Azure Login Action using a Service Principal and you can do this by running Az CLI or Azure PowerShell scripts

The Azure login action supports two different ways of authenticating with Azure :
- _Service principal with [secrets](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows#use-the-azure-login-action-with-a-service-principal-secret)_

- _OpenID Connect (OIDC) with a Azure service principal using a [Federated Identity Credential](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows#use-the-azure-login-action-with-openid-connect)_


### 3. Create a Service Principal using Az CLI commands by signing-in interactively 

```
az login 
```

- If the CLI can open your default browser, it will do so and load an Azure sign-in page.

- Otherwise, open a browser page at https://aka.ms/devicelogin and enter the authorization code displayed in your terminal.
- Sign in with your account credentials in the browser.
- Run the below command if you have multiple subscriptions 

```
az account set --subscription <xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>
az account show
```
<img src= /docs/images/az-account-show.jpg width=600 height=400>



### 4. Configure Deployment Credentials 

For using credentials like a Service Principal we will need to add them as secrets < Encrypted secrets - GitHub Docs > in GitHub the repository

Follow the below steps to configure secrets for the authentication within the GitHub workflow :

-	Go to your GitHub repository settings  and a ‘New repository secrets’ from Secrets menu
-	Store the output of the below az cli < az cli (microsoft.com) > command as a variable (e.g. AZURE_CREDENTIALS). This will be referenced back in the workflow file


```
az ad sp create-for-rbac --name "enterprise-scale-apim-app" --role contributor \
                        --scopes /subscriptions/{subscription-id} \
                        --sdk-auth
```

[replace {subscription-id}, {resource-group} with the subscription, resource group details]
[the above command should output a JSON object like this]

```
  {
    "clientId": "<GUID>",
    "clientSecret": "<GUID>",
    "subscriptionId": "<GUID>",
    "tenantId": "<GUID>",
    (...)
  }
```
<img src= /docs/images/secrets.png width=800 height=425>


### 5. Run the workflow 

