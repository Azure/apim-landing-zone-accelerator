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

## Other Considerations
1. This is a way you can execute bicep deployment:
    ```
    az deployment sub create --location eastus --name am --template-file main.bicep --parameters workloadName=am environment=dev
2. Please leverage issues if you have any feedback or request on how we can improve on this repository
