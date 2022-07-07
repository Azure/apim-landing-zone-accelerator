#bash
az login --use-device-code
az account set --subscription 8308f340-4d69-4343-a5af-5437a6121b15
az account show

#output from this should be stored in a secret/variable called AZURE_CREDENTIALS
az ad sp create-for-rbac --name "enterprise-scale-apim-app" --role contributor --scopes /subscriptions/8308f340-4d69-4343-a5af-5437a6121b15 --sdk-auth