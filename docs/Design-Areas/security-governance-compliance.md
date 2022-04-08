# Security, Governance and Compliance
## Design Considerations
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
## Design Recommendations
- Deploy a Web Application Firewall (WAF) in front of API Management to provide protection against common web application exploits and vulnerabilities. 
- Use [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts) to securely store and manage secrets and make them available through named values within API Management.
- Create a system assigned Managed Identity within API Management to establish trust relationships between the service and other resources protected by Azure Active Directory, including Key Vault and backend services.
- Use Azure [built-in roles](https://docs.microsoft.com/en-us/azure/api-management/api-management-role-based-access-control#built-in-roles) to provide least privilege permissions to manage the API Management service.
- Configure diagnostics settings within API Management to output logs and metrics to Azure Monitor.
- APIs should only be accessible over HTTPS to protect data in-transit and ensure its integrity.
- Use the latest TLS version when encrypting information in transit and disable outdated and unnecessary protocols and ciphers when possible.
- Implement an error handling policy at the global level.
- All policies should call "<base/ >"
- Do not enable 3DES, TLS1.1 or lower encryption protocols unless absolutely required. 

 
