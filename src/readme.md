# Steps to deploy the function and APIs

- [Import](https://learn.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?view=azure-devops) this repo to an Azure DevOps Repo
- Create two [ARM service connections](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops) each scoped to the APIM resource group and the function app resource group
- Make sure that the *Default* agent pool has _Grant access to all pipelines_ selected
- Create an [Artifacts Feed](https://learn.microsoft.com/en-us/azure/devops/artifacts/get-started-nuget?view=azure-devops&tabs=windows#create-a-feed). For ex, name as todo-apis

## Deploy the backend

- Create a pipeline using the deploy-function.yml file
- Add [variables](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/variables?view=azure-devops&tabs=yaml%2Cbatch#access-variables-through-the-environment) to the pipeline
  - armServiceConnection - the service connection scoped to the backend resource group
  - functionAppName - name of the function app in the backend resource group
  - poolName
- Run the pipeline

_note: pool name is Default if using the construction set scripts_

## Deploy the APIs

### Generator pipeline

- Create a pipeline using the apim-generator.yml file. This generates the ARM templates from open api specification
- Add variables for
  - poolName
  - artifacts-feed
- Run the pipeline

_note:pool name is Default if using the construction set scripts_
_note:artifacts-feed is the name created in the first step_

### Collector pipeline

- Create a pipeline using the apim-collector.yml file. This collects the artifacts from the generator and deploys.
- Add variables fro
  - poolName
  - apimResourceGroup
  - apimName
  - artifacts-feed
  - todoServiceUrl - url of the function app (ex. https://{funcappname}.azurewebsites.net/api)
  - armServiceConnection - the service connection scoped to the apim resource group

- Run the pipeline

### Test

Access the api at https://{application gateway hostname}/todo/todo
