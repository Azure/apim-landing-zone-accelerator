> The H1 title is the same as the title metadata. Don't enter it here, but as the **name** value in the corresponding YAML file.

This solution deploys the Enterprise Scale API Management Landing Zone a secure, opinionated accelerator enabling developers to rapidly onboard APIs to API management  [**Deploy this solution**.](#deploy-the-solution)

![Architecture](./../images/arch.png)

_Download a [Visio file](https://arch-center.azureedge.net/architecture.vsdx) that contains this architecture diagram. This file must be uploaded to `https://arch-center.azureedge.net/`_

## Architecture

The architecture leverages the following components :

### Components

- **[API Management](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts)** a managed service that allows customers to manage across hybrid and multi-cloud. API management acts as a facade to abstract backend architecture and provides control and security for API observability and consumption for both internal and external users.

- **[Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview)** a serverless solution that allows the users to focus more on blocks of code to be executed with minimal infrastructure management. Functions can be hosted in [a variety of hosting plans](https://docs.microsoft.com/en-us/azure/azure-functions/functions-scale) whereas this reference architecture uses the premium plan due to the use of private endpoints.

- **[Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/overview)** a managed service acting as a layer 7 load balancer and [web application firewall](https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview) in this use case the application gateway protects the internal APIM instance allowing for use of internal and external mode.

- **[Azure Private DNS Zones](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone)** allow users to manage and resolve domain names within a virtual network without needing to implement a custom DNS solution. A Private Azure DNS zone can be aligned to one or more virtual networks through [virtual network links](https://docs.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links). Due to the internal mode of the APIM instance this reference architecture uses, a private DNS zone is required.

- **[Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)** is a feature of Azure Monitor that helps Developers detect anomalies, diagnose issues, and understand usage patterns with extensible application performance management and monitoring for live web apps. A variety of platforms including .NET, Node.js, Java, and Python are supported for apps that are hosted in Azure, on-prem, hybrid, or other public clouds. Application Insights is included as part of this reference architecture to monitor behaviors of the deployed application.

- **[Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview)** is a feature of Azure Monitor that allows users to edit and run log queries with data in Azure Monitor Logs, optionally from within the Azure portal. Developers can run simple queries for a set of records or use Log Analytics to perform advanced analysis and visualize the results. Log Analytics is configured as part of this reference architecture to aggregate all the monitoring logs for additional analysis and reporting.

- **[Azure Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/overview)** is an on-demand, scalable computing resource that can be used to host a number of different workloads. In this reference architecture, virtual machines are used to provide a management jumpbox server, as well as a host for the DevOps Agent / GitHub Runner.

- **[Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts)** is a cloud service to securely store and access secrets, ranging from API keys and passwords to certificates and cryptographic keys. While this reference architecture does not store secrets in the Key Vault as part of the infrastructure deployment of this reference architecture, the Key Vault is deployed to facilitate secret management for future code deployments.

- **[Azure Bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview)** is a Platform-as-a-Service service provisioned within the developer's virtual network which provides secure RDP/SSH connectivity to the developer's virtual machines over TLS from the Azure portal. With Azure Bastion, virtual machines no longer require a public IP address to connect via RDP/SSH. This reference architecture uses Azure Bastion to access the DevOps Agent / GitHub Runner server or the management jump box server.

## Considerations

These considerations implement the pillars of the Azure Well-Architected Framework, which is a set of guiding tenets that can be used to improve the quality of a workload. For more information, see [Microsoft Azure Well-Architected Framework](/azure/architecture/framework).

- Review the reference implementation resources at [LOB-ILB-ASEv3](../../reference-implementations/LOB-ILB-ASEv3/) to better understand the specifics of this implementation.
- It is recommended that you clone this repo and modify the reference implementation resources to suit your requirements and your organization's specific landing zone guidelines.
- Ensure that the service principal used to deploy the solution has the required permissions to create the resource types listed above.
- Consider the CI/CD service you will use for deploying the reference implementation. As this reference implementation is an internal API Management, a self-hosted agent is needed to execute the deployment pipelines.  As such the choice is to use either a DevOps Agent or a GitHub Runner. Refer to the [user guide](../README.md) on specific configuration values required for each.
- Consider the region to which you intend deploying this reference implementation, and consult the [API Management Regions list](https://docs.microsoft.com/en-us/azure/api-management/zone-redundancy) to ensure the selected region has support for zone redundancy.

### Scalability considerations

- Deploy at least two scale units spread over two AZs per region for best availability and performance

### Availability considerations

- Use [Application Gateway for external access of an internal APIM instance](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-integrate-internal-vnet-appgateway)
- Deploy the gateway in a vnet to allow access to backend services in the network
- VNet peering provides great performance in a region but has a scalability limit of max 500 networks, if you require more workloads to be connected, use [hub spoke](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli) or PLE

### Manageability considerations

- APIM configurations are represented as ARM templates and an infrastructure-as-code mindset should be embraced.
- The Uri /status-0123456789abcdef can be used as a common health endpoint for the APIM service.
- The APIM Service is not a WAF. Deploy Azure App Gateway in front to add additional layers of protection
- Client certificate negotiation is enabled is a per-gateway configuration
- Certificates updated in the key vault are automatically rotated in API Management and is updated within 4 hours.
- Utilize Key Vault for Certificate storage, notification, and rotation

### Security considerations

- API Management [validation policies](https://docs.microsoft.com/en-us/azure/api-management/validation-policies) are available to validate API requests and responses against an OpenAPI schema. These are not a replacement for a [Web Application Firewall](https://docs.microsoft.com/en-us/azure/web-application-firewall/overview) but can provide additional protection against some threats. Note that adding validation policies can have performance implications, so we recommend performance load tests to assess their impact on API throughput.
- Deploy a Web Application Firewall (WAF) in front of API Management to provide protection against common web application exploits and vulnerabilities.

## Deploy this scenario

To deploy the API management landing zone accelerator there are several methodologies you can choose from. Select one from the list below and follow the deployment steps.

| Deployment Methodology| GitHub Action YAML| User Guide|
|--------------|--------------|--------------|
| [Bicep](/reference-implementations/AppGW-IAPIM-Func/bicep) |[es-apim.yml](/.github/workflows/es-apim.yml)| [README](/docs/README.md)
| ARM (Coming soon) ||
| Terraform (Coming soon)||

## Next steps

* [Identity and access management for the Azure API Management landing zone accelerator](/azure/cloud-adoption-framework/scenarios/app-platform/api-management/identity-and-access-management)
* [CI/CD for API Management using Azure Resource Manager templates](/azure/api-management/devops-api-development-templates)

## Related resources

* [Recommendations and Considerations](docs/README.md#enterprise-scale-architecture)
* [API Ops](https://github.com/Azure/apiops)