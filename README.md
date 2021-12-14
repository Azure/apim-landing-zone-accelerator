# Enterprise-Scale-APIM

This is a repository ([aka.ms/EnterpriseScale-APIM](https://aka.ms/EnterpriseScale-APIM)) that contains both enteprrise architecture (proven recommendations and considerations) and reference implementaion (deployable artifacts for a common implementations). 

## Enterprise-Scale Architecture
The enterprise architecture is broken down into six different design areas, where you can find the links to each at:
| Design Area|
|------|
|[Identity and Access Management](https://github.com/cykreng/Enterprise-Scale-APIM/blob/main/docs/Design-Areas/identity-access-mgmt.md)|
|[Network Topology and Connectvity](https://github.com/cykreng/Enterprise-Scale-APIM/blob/main/docs/Design-Areas/networking.md)|
|[Management and Monitoring](https://github.com/cykreng/Enterprise-Scale-APIM/blob/main/docs/Design-Areas/mgmt-monitoring.md)|
|[Business Continuity and Disaster Recovery](https://github.com/cykreng/Enterprise-Scale-APIM/blob/main/docs/Design-Areas/BCDR.md)|
|[Security, Governance, and Compliance](https://github.com/cykreng/Enterprise-Scale-APIM/blob/main/docs/Design-Areas/security-governance-compliance.md)|
|[Application Automation and DevOps](https://github.com/cykreng/Enterprise-Scale-APIM/blob/main/docs/Design-Areas/automation-devops.md)|

## Enterprise-Scale Reference Implementation
In this repo you will also find reference implementations with supporting Infrastructe as Code templates. More reference implementations will be added as they become available. 

---
### Reference Implementation 1: App Gateway with internal APIM instance with Azure Functions as backend
Architectural Diagram:
![image](https://user-images.githubusercontent.com/37597107/133897334-13764cec-c279-4517-8218-a365c1524388.png)

Resources Deployed:
![image](https://user-images.githubusercontent.com/37597107/133897343-220a2e78-4f5a-4623-87bd-388a02949b96.png)

Deployment Details:
| Deployment Methodology| GitHub Action YAML|
|--------------|--------------|
| [Bicep](https://github.com/cykreng/Enterprise-Scale-APIM/tree/main/deployment/bicep) |[apim-cs.yml](https://github.com/cykreng/Enterprise-Scale-APIM/blob/workflow/.github/workflows/apim-cs.yml)|
| ARM (Coming soon) ||
| Terraform (Coming soon)||
---

## Other Considerations
1. This is a way you can execute bicep deployment:
    ```
    az deployment sub create --location eastus --name am --template-file main.bicep --parameters workloadName=am environment=dev
2. Please leverage issues if you have any feedback or request on how we can improve on this repository
