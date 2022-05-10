> The H1 title is the same as the title metadata. Don't enter it here, but as the **name** value in the corresponding YAML file.

# DRAFT

This solution deploys the Enterprise Scale API Management Landing Zone a secure, opinionated accelerator enabling developers to rapidly onboard APIs to API management  [**Deploy this solution**.](#deploy-the-solution)

![alt text.](./docs/images/arch.png)

_Download a [Visio file](https://arch-center.azureedge.net/architecture.vsdx) that contains this architecture diagram. This file must be uploaded to `https://arch-center.azureedge.net/`_

## Architecture

### Components

- [**API Management**](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts) is a managed service that allows customers to manage across hybrid and multi-cloud. API management acts as a facade to abstract backened architecture and provides control and security for API observability and consumption for both internal and external users.

- **[Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview)** is a serverless solution that allows the users to focus more on blocks of code to be executed with minimal infrastructure management. Functions can be hosted in [a variety of hosting plans](https://docs.microsoft.com/en-us/azure/azure-functions/functions-scale) whereas this reference architecture uses the premium plan due to the use of private endpoints.

- [**Application Gateway**](https://docs.microsoft.com/en-us/azure/application-gateway/overview)

- **[Azure Private DNS Zones](https://docs.microsoft.com/en-us/azure/dns/private-dns-privatednszone)** allow users to manage and resolve domain names within a virtual network without needing to implement a custom DNS solution. A Private Azure DNS zone can be aligned to one or more virtual networks through [virtual network links](https://docs.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links). Due to the internal mode of the APIM instance this reference architecture uses, a private DNS zone is required.

- **[Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)** is a feature of Azure Monitor that helps Developers detect anomalies, diagnose issues, and understand usage patterns with extensible application performance management and monitoring for live web apps. A variety of platforms including .NET, Node.js, Java, and Python are supported for apps that are hosted in Azure, on-prem, hybrid, or other public clouds. Application Insights is included as part of this reference architecture to monitor behaviors of the deployed application.

- **[Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview)** is a feature of Azure Monitor that allows users to edit and run log queries with data in Azure Monitor Logs, optionally from within the Azure portal. Developers can run simple queries for a set of records or use Log Analytics to perform advanced analysis and visualize the results. Log Analytics is configured as part of this reference architecture to aggregate all the monitoring logs for additional analysis and reporting.

- **[Azure Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/overview)** is an on-demand, scalable computing resource that can be used to host a number of different workloads. In this reference architecture, virtual machines are used to provide a management jumpbox server, as well as a host for the DevOps Agent / GitHub Runner.

- **[Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts)** is a cloud service to securely store and access secrets ranging from API keys and passwords to certificates and cryptographic keys. While this reference architecture does not store secrets in the Key Vault as part of the infrastructure deployment of this reference architecture, the Key Vault is deployed to facilitate secret management for future code deployments.

- **[Azure Bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview)** is a Platform-as-a-Service service provisioned within the developer's virtual network which provides secure RDP/SSH connectivity to the developer's virtual machines over TLS from the Azure portal. With Azure Bastion, virtual machines no longer require a public IP address to connect via RDP/SSH. This reference architecture uses Azure Bastion to access the DevOps Agent / GitHub Runner server or the management jumpbox server.

## Recommendations

The following recommendations apply for most scenarios. Follow these recommendations unless you have a specific requirement that overrides them.

_Include considerations for deploying or configuring the elements of this architecture._

## Scalability considerations

- Utilize [Availability Zones](https://docs.microsoft.com/en-us/azure/api-management/zone-redundancy), the number of Units selected must distribute evenly across the zones
- Be aware of maximum[ throughput limits](https://azure.microsoft.com/en-us/pricing/details/api-management/) of each APIM SKU
- Be aware of the maximum number of [scale-out units](https://azure.microsoft.com/en-us/pricing/details/api-management/) per APIM SKU
- Be aware of the maximum throughputs are approximate and not guarantees
- Consider the number of service units required through [configuration](https://docs.microsoft.com/en-us/azure/api-management/upgrade-and-scale#scale-your-api-management-service) or [auto-scaling](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-autoscale)
- APIM does not scale-out automatically, additional configuration is required.
- There is no downtime during a scale-out event
- Be aware of the possible performance impact of AppInsights logging at high loads.
- Be aware that the number of inbound and outbound policies applied and their impact to performance
- 
## Availability considerations

- Determine the Recovery Time Objective (RTO) and Recovery Point Objective (RPO) for the APIM instance(s) that we want to protect and the value chains they support (consumers &amp; providers). Consider the feasibility of deploying fresh instances or having a hot / cold standby.
- APIM can be [backed up using its Management REST API](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-disaster-recovery-backup-restore#calling-the-backup-and-restore-operations). Backups expire after 30 days. Be aware of [what APIM does not back up](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-disaster-recovery-backup-restore#what-is-not-backed-up)
- Decide if the APIs are accessible externally or internally
- Decide if private end point connectivity is required
- Decide how to connect to external (3rd party) workloads
- Decide whether [virtual network connection](https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet?tabs=stv2#enable-vnet-connection) is required and the access type for virtual network connection ([external](https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet?tabs=stv2#enable-vnet-connection) or [internal](https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-internal-vnet)).
- Decide whether connectivity to on-premises or multi-cloud environments is required.

## Manageability considerations

- Each API team can push updates from their own developer repo to their own development APIM instance.
  - What does this mean from a network planning perspective?
  - What about other non prod environments (QA, Staging etc)
  - Consider how products etc. should be managed/versioned especially if multiple teams use the same products.
  - Consider the testing strategy for API and policies.
- Consider using policies for [access restriction](https://docs.microsoft.com/en-us/azure/api-management/api-management-access-restriction-policies#AccessRestrictionPolicies), [authentication](https://docs.microsoft.com/en-us/azure/api-management/api-management-authentication-policies#AuthenticationPolicies), [caching](https://docs.microsoft.com/en-us/azure/api-management/api-management-caching-policies#CachingPolicies), [cross domain](https://docs.microsoft.com/en-us/azure/api-management/api-management-cross-domain-policies#CrossDomainPolicies), [transformation](https://docs.microsoft.com/en-us/azure/api-management/api-management-transformation-policies#TransformationPolicies), [Dapr integration](https://docs.microsoft.com/en-us/azure/api-management/api-management-dapr-policies), and [validation](https://docs.microsoft.com/en-us/azure/api-management/validation-policies)
- Policies are code and should be under version control
- The Uri /status-0123456789abcdef can be used as a common health endpoint for the APIM service.
- The APIM Service is not a WAF. Deploy Azure App Gateway in front to add additional layers of protection
- Client certificate negotiation is enabled is a per-gateway configuration
- Certificates updated in the key vault are automatically rotated in API Management and is updated within 4 hours.
- Secret in Key Vault is updated within 4 hours after being set. You can also manually refresh the secret using the Azure portal or via the management REST API.
- [Custom Domains](https://docs.microsoft.com/en-us/azure/api-management/configure-custom-domain) can be applied to all endpoints or just a subset. The Premium tier supports setting multiple host names for the Gateway endpoint.
- APIM can be backed up using its Management REST API. Backups expire after 30 days. Be aware of what APIM does not back up.
- [Named values](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-properties?tabs=azure-portal) are global in scope.
- API Operations can be grouped into [Products](https://docs.microsoft.com/en-us/azure/api-management/api-management-terminology#term-definitions) and Subscriptions. The design will be based on actual business requirements.

## Security considerations

- Research the available [built-in RBAC roles](https://docs.microsoft.com/en-us/azure/api-management/api-management-role-based-access-control#built-in-roles) available for the API Management service
- Consider using [built-in Azure Policies](https://docs.microsoft.com/en-us/azure/api-management/policy-reference) to govern the APIM instance
- Consider what level of logging is necessary to meet your organization’s compliance requirements.
- Consider how you want to secure your frontend APIs beyond using subscription keys. OAuth 2.0, OpenID Connect, and mutual TLS are common options with built-in support.
- Think about how you want to protect your backend services behind API Management. Client certificates and OAuth 2.0 are two supported options.
- Consider which client and backend [protocols and ciphers](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-manage-protocols-ciphers) are required to meet your security requirements.
- API Management [validation policies](https://docs.microsoft.com/en-us/azure/api-management/validation-policies) are available to validate API requests and responses against an OpenAPI schema. These are not a replacement for a [Web Application Firewall](https://docs.microsoft.com/en-us/azure/web-application-firewall/overview) but can provide additional protection against some threats. Note that adding validation policies can have performance implications, so we recommend performance load tests to assess their impact on API throughput.
- Consider which identity providers besides Azure AD need to be supported.
- Consider how non-compliance should be detected.
- Consider how to standardize error responses returned by APIs.
- Decide on the access management for APIM services through all possible channels like portal, ARM REST API, DevOps etc.
- Decide on the access management for APIM entities.
- Decide on [how to sign up and authorize the developer accounts](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-create-or-invite-developers).
- Decide on how subscriptions are used.
- Decide on the visibility of [products](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#--products) and APIs on the developer portal using [groups](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#--groups).
- Decide on access revocation policies.
- Decide on reporting requirements for access control.

## Deploy this scenario
To deploy the API management landing zone accelerator there are several methodologies you can choose from. Select one from the list below and follow the deployment steps.

| Deployment Methodology| GitHub Action YAML| User Guide|
|--------------|--------------|--------------|
| [Bicep](/reference-implementations/AppGW-IAPIM-Func/bicep) |[es-apim.yml](/.github/workflows/es-apim.yml)| [README](/docs/README.md)
| ARM (Coming soon) ||
| Terraform (Coming soon)||

## Next steps

Link to Docs and Learn articles. Could also be to appropriate sources outside of Docs, such as GitHub repos, third-party documentation, or an official technical blog post.

Examples:
* [Azure Machine Learning documentation](/azure/machine-learning)
* [What are Azure Cognitive Services?](/azure/cognitive-services/what-are-cognitive-services)

## Related resources

Use "Related resources" for architecture information that's relevant to the current article. It must be content that the Azure Architecture Center TOC refers to, but may be from a repo other than the AAC repo.

Links to articles in the AAC repo should be repo-relative, for example (../../solution-ideas/articles/article-name.yml).

Here is an example section:

Fully deployable architectures:

* [Chatbot for hotel reservations](/azure/architecture/example-scenario/ai/commerce-chatbot)
* [Build an enterprise-grade conversational bot](/azure/architecture/reference-architectures/ai/conversational-bot)
* [Speech-to-text conversion](/azure/architecture/reference-architectures/ai/speech-ai-ingestion)