# Application Automation and DevOps
## Design Considerations

- Each API team can push updates from their own developer repo to their own development APIM instance.
    - What does this mean from a network planning perspective?
    - What about other non prod environments (QA, Staging etc)
- Consider how products etc should be managed/versioned especially if multiple teams use the same products.
- Consider the testing strategy for API and policies.
## Design Recommendations
- A central team (e.g. APIM admin team) manages the production APIM environment.
- APIM configurations are represented as ARM templates and an infrastructure-as-code mindset should be embraced.
- The APIM admin team will publish configuration changes to the production APIM environment from a Git repository (publisher repo) owned by the APIM admin team.
- Each individual API team may fork the publisher repo to have their own developer repo to work from.
- Each team can use the APIM Reskit  or the VS Code APIM extension to extract the relevant artifacts from their development APIM instance. These artifacts are based on ARM and should be committed to the API team’s Git repo. 
    - Do not use the [Git integration](https://docs.microsoft.com/en-us/azure/api-management/api-management-configuration-repository-git)
- Service Templates and Shared templates should be in a separate repo
- Use the [“Extract all APIs with seperated api folders“ option](https://github.com/Azure/azure-api-management-devops-resource-kit/blob/master/src/APIM_ARMTemplate/README.md#extractor)
- Changes to artifacts should be done to the extracted artifacts and then committed to Git. These should be deployed to a dev environment 
- To promote to the centralized environments (staging, production), API teams can submit a pull request (PR) to merge their changes to the publisher repo. 
- The APIM admin team validates the PR.
    - Ideally most of the validations are automated as part of submitting a PR.
- The IAC templates should be in a different repo – and deployed in a deployment pipeline
    - Separate infrastructure deployment from application deployment. Core infrastructure changes less than applications. Treat each type of deployment as a separate flow and pipeline.
- Once changes are approved and merged successfully, the APIM admin team can deploy the changes to the centrally managed environment (staging, production) in coordination with agreed-upon API team schedules. 


