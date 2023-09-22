# Enterprise-Scale-APIM

This is a repository ([aka.ms/EnterpriseScale-APIM](https://aka.ms/EnterpriseScale-APIM)) that contains both enterprise architecture (proven recommendations and considerations) and reference implementation (deployable artifacts for a common implementations).

## Enterprise-Scale Architecture

The enterprise architecture is broken down into six different design areas, where you can find the links to each at:
| Design Area|Considerations|Recommendations|
|:--------------:|:--------------:|:--------------:|
| Identity and Access Management|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/identity-and-access-management#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/identity-and-access-management#design-recommendations)|
| Network Topology and Connectivity|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/network-topology-and-connectivity#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/network-topology-and-connectivity#design-recommendations)|
| Security|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/security#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/security#design-recommendations)|
| Management|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/management#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/management#design-recommendation)|
| Governance|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/governance#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/governance#design-recommendations)|
| Platform Automation and DevOps|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/platform-automation-and-devops#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/platform-automation-and-devops#design-recommendations)|

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
| [Terraform](reference-implementations/AppGW-IAPIM-Func/terraform) | [terraform-es-apim.yml](.github/workflows/terraform-es-apim.yml) | [README](reference-implementations/AppGW-IAPIM-Func/terraform/README.md) |
---

## Other Considerations

1. This is a way you can execute bicep deployment:

    ```azcli
    az deployment sub create --location eastus --name am --template-file main.bicep --parameters workloadName=am environment=dev

2. Please leverage issues if you have any feedback or request on how we can improve on this repository

---

## Got a feedback

Please leverage issues if you have any feedback or request on how we can improve on this repository.

---
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at https://go.microsoft.com/fwlink/?LinkId=521839. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.

### Telemetry Configuration

Telemetry collection is on by default.

To opt-out, set the variable enableTelemetry to `false` in Bicep/ARM file and disable_terraform_partner_id to `false` on Terraform files.

---

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

