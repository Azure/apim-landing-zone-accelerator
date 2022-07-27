# Enterprise-Scale-APIM

This is a repository ([aka.ms/EnterpriseScale-APIM](https://aka.ms/EnterpriseScale-APIM)) that contains both enterprise architecture (proven recommendations and considerations) and reference implementaion (deployable artifacts for a common implementations).

## Enterprise-Scale Architecture

The enterprise architecture is broken down into six different design areas, where you can find the links to each at:
| Design Area|Considerations|Recommendations|
|:--------------:|:--------------:|:--------------:|
| Identity and Access Management|[Design Considerations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/identity-and-access-management#design-considerations)|[Design Recommendations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/identity-and-access-management#design-recommendations)|
| Network Topology and Connectivity|[Design Considerations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/network-topology-and-connectivity#design-considerations)|[Design Recommendations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/network-topology-and-connectivity#design-recommendations)|
| Security|[Design Considerations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/security#design-considerations)|[Design Recommendations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/security#design-recommendations)|
| Management|[Design Considerations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/management#design-considerations)|[Design Recommendations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/management#design-recommendation)|
| Governance|[Design Considerations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/governance#design-considerations)|[Design Recommendations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/governance#design-recommendations)|
| Platform Automation and DevOps|[Design Considerations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/platform-automation-and-devops#design-considerations)|[Design Recommendations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/platform-automation-and-devops#design-recommendations)|

## Enterprise-Scale Reference Implementation

In this repo you will also find reference implementations with supporting Infrastructure as Code templates. More reference implementations will be added as they become available.

---

### Reference Implementation 1: App Gateway with internal APIM instance with Azure Functions as backend

Architectural Diagram:
![image](/docs/images/arch.png)

Resources Deployed:
![image](/docs/images/deployed-items.png)

Deployment Details:
| Deployment Methodology| GitHub Action YAML| User Guide|
|--------------|--------------|--------------|
| [Bicep](/reference-implementations/AppGW-IAPIM-Func/bicep) |[es-apim.yml](/.github/workflows/es-apim.yml)| [README](/docs/README.md)
| [ARM](/reference-implementations/AppGW-IAPIM-Func/azure-resource-manager/apim-arm.js) | Not provided* |
| Terraform (Coming soon)||
---

## Other Considerations

1. This is a way you can execute bicep deployment:

    ```azcli
    az deployment sub create --location eastus --name am --template-file main.bicep --parameters workloadName=am environment=dev

2. Please leverage issues if you have any feedback or request on how we can improve on this repository

