# APIM-ESLZ

Azure API Management Enterprise Scale Landing Zones development  

To generate the Azure subscription credentials, follow the guidance provided in the Docs:
[Deploy Azure AppService with GitHub Actions](https://docs.microsoft.com/en-us/azure/app-service/deploy-github-actions?tabs=userlevel#generate-deployment-credentials "Deploy Azure AppService with GitHub Actions")

Note: The necessary role assignments can be done afterwards, but the creation of the service principal is required before you can run the action.
example to generate the service principal:

``` Azure CLI

az ad sp create-for-rbac -n "github.com/your-username/your-repo" --sdk-auth true --skip-assignment true

```

This will generate the credentials and output json snippet that you can use to set the GitHub Secret "AZURE_CREDENTIALS" as referenced in the actions.
