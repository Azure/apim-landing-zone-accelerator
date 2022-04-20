# Enterprise-Scale-APIM

This is a repository ([aka.ms/EnterpriseScale-APIM](https://aka.ms/EnterpriseScale-APIM)) that contains both enterprise architecture (proven recommendations and considerations) and reference implementaion (deployable artifacts for a common implementations). 

## Enterprise-Scale Architecture
The enterprise architecture is broken down into six different design areas, where you can find the links to each at:
| Design Area|Considerations|Recommendations|
|:--------------:|:--------------:|:--------------:|
| Identity and Access Management|[Design Considerations](/docs/Design-Areas/identity-access-mgmt.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/identity-access-mgmt.md#design-recommendations)|
| Network Topology and Connectivity|[Design Considerations](/docs/Design-Areas/networking.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/networking.md#design-recommendations)|
| Management and Monitoring|[Design Considerations](/docs/Design-Areas/mgmt-monitoring.md#design-consideration)|[Design Recommendations](/docs/Design-Areas/mgmt-monitoring.md#design-recommendation)|
| Business Continuity and Disaster Recovery|[Design Considerations](/docs/Design-Areas/BCDR.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/BCDR.md#design-recommendations)|
| Security, Governance, and Compliance|[Design Considerations](/docs/Design-Areas/security-governance-compliance.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/security-governance-compliance.md#design-recommendations)|
| Application Automation and DevOps|[Design Considerations](/docs/Design-Areas/automation-devops.md#design-considerations)|[Design Recommendations](/docs/Design-Areas/automation-devops.md#design-recommendations)|

## Enterprise-Scale Reference Implementation
In this repo you will also find reference implementations with supporting Infrastructe as Code templates. More reference implementations will be added as they become available. 

---
### Reference Implementation 1: App Gateway with internal APIM instance with Azure Functions as backend
Architectural Diagram:
![image](https://user-images.githubusercontent.com/37597107/133897334-13764cec-c279-4517-8218-a365c1524388.png)

Resources Deployed:
![image](https://user-images.githubusercontent.com/37597107/133897343-220a2e78-4f5a-4623-87bd-388a02949b96.png)

Deployment Details:
| Deployment Methodology| GitHub Action YAML| User Guide|
|--------------|--------------|--------------|
| [Bicep](/reference-implementations/AppGW-IAPIM-Func/bicep) |[es-apim.yml](/.github/workflows/es-apim.yml)| [README](/docs/README.md)
| ARM (Coming soon) ||
| Terraform (Coming soon)||
---

## Generating the ARM Template

### Process

When we developed this Landing Zone Accelerator, we chose Bicep as our first Infrastructure as Code deployment method due to its many advantages. We were excited about trying a new IaC experience and drawn to its declarative nature and ease to onboard compared to ARM templates. Another benefit that we recognized was the capability to generate ARM templates from a Bicep template, which we leverage as part of our GitHub workflow. 

During our deployment, we added several Bicep validation / preflight checks as seen in our [Action yaml file](/.github/workflows/es-apim.yml). If those validations pass without errors, we continue to deploy the Bicep template. If Bicep deploys without any error, we begin to generate the ARM template as a next [Job](https://docs.github.com/en/actions/using-jobs/using-jobs-in-a-workflow) in GitHub Action using the command below. We have opted to not include additional validation steps solely on the ARM template given the reasons specified below. 

```yaml
az bicep build --file main.bicep --outfile ../azure-resource-manager/apim-arm.json
```

### Storing the ARM Template

After the ARM Template is generated, we create a branch from the main branch and uses the 'run_number' of GitHub Action to push the ARM template to the newly created branch.

Again, you can find the details in [Action yaml file](/.github/workflows/es-apim.yml)

### Generated ARM Template Validation
---
There are several ways to **Validate** an ARM Template;

- Syntax: Code

- Behavior: What is the code doing that you may want to be aware of? Are you handling secure parameters (e.g. secrets) correctly? Is the use of location for resources reasonable? Do you have practices that may cause problems across environments (subs, clouds, etc.)?

- Result: What does the code do (deploy) or not that you may want to be aware of? (no NSGs or NSGs too permissive, password vs key authentication)

- Intent: Does the code do what it is intended to do?

- Success: Does the code successfully deploy?

**Syntax**: For syntax check ```bicep build``` completes that validation.

**Behavior**: Bicep completes most of behavior checks, while [arm-ttk](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/test-toolkit) has some additional capabilities that will eventually be incorporated into Bicep or other tools. 

**Result**: This can be covered using [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/overview). 

**Intent**: We can run what-if scenarios on the ARM Template. This, however, requires human interaction and thus cannot be automated. 

**Success**: Since before ARM Template, Bicep template finished successfully (otherwise ARM Template generation step would not start) so we are sure that ARM Template will work, so no need to add any validation on that. This doesn't guarantee a successful deployment as there may be other factors such as region availability, user permission, policy conflict that could lead to a failed deployment even if the ARM template is completely valid. 

As a result, since the ARM Template is  generated from the Bicep template, additional steps to **validate the ARM Template** are negligible.

---

## Other Considerations
1. This is a way you can execute bicep deployment:
    ```
    az deployment sub create --location eastus --name am --template-file main.bicep --parameters workloadName=am environment=dev
2. Please leverage issues if you have any feedback or request on how we can improve on this repository

