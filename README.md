# Azure API Management Landing Zone Accelerator

Azure API Management Landing Zone Accelerator provides packaged guidance with reference architecture and reference implementation along with design guidance recommendations and considerations on critical design areas for provisioning APIM with a secure baseline. They are aligned with industry proven practices, such as those presented in [Azure landing zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/) guidance in the Cloud Adoption Framework.

## Reference Architecture

![image](/docs/images/apim-secure-baseline.jpg)

## :mag: Design areas

The enterprise architecture is broken down into six different design areas, where you can find the links to each at:
| Design Area|Considerations|Recommendations|
|:--------------:|:--------------:|:--------------:|
| Identity and Access Management|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/identity-and-access-management#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/identity-and-access-management#design-recommendations)|
| Network Topology and Connectivity|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/network-topology-and-connectivity#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/network-topology-and-connectivity#design-recommendations)|
| Security|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/security#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/security#design-recommendations)|
| Management|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/management#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/management#design-recommendation)|
| Governance|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/governance#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/governance#design-recommendations)|
| Platform Automation and DevOps|[Design Considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/platform-automation-and-devops#design-considerations)|[Design Recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/api-management/platform-automation-and-devops#design-recommendations)|

## :rocket: Deployment scenarios

This repo contains the Azure landing zone accelerator's reference implementations, all with supporting *Infrastructure as Code* artifacts. The scenarios covered are:

### :arrow_forward: [Scenario 1: Azure API Management - Secure Baseline](scenarios/apim-baseline/README.md)

Deploys APIM with a secure baseline configuration with no backends and a sample API. 

### :arrow_forward: [Scenario 2: Azure API Management - Function Backend](scenarios/workload-functions/README.md)

On top of the secure baseline, deploys a private Azure function as a backend and provision APIs in APIM to access the function.

### :arrow_forward: [Scenario 3: Azure API Management - Gen AI Backend](scenarios/workload-genai/README.md)

On top of the secure baseline, deploys private Azure OpenAI endpoints (3 endpoints) as backend and provision API that can handle [multiple use cases.](./scenarios/workload-genai/README.md#scenarios-handled-by-this-accelerator)

*More reference implementation scenarios will be added as they become available.*

### Supported Regions

Some of the new Azure OpenAI policies are not available in al the regions yet. If you see the deployment failures, try chosing a different region. The following regions are more likely to work.

```shell
australiacentral, australiaeast, australiasoutheast, brazilsouth, eastasia, francecentral, germanywestcentral, koreacentral, northeurope, southeastasia, southcentralus, uksouth, ukwest, westeurope, westus2, westus3
```

## Got a feedback

Please leverage issues if you have any feedback or request on how we can improve on this repository.

---

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at https://go.microsoft.com/fwlink/?LinkId=521839. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.

### Telemetry Configuration

Telemetry collection is on by default.

To opt-out, set the variable ENABLE_TELEMETRY to `false` in [.env](./scenarios/.env) file.

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
