# Security, Governance and Compliance
## Design Considerations
- Research the available built-in RBAC roles available for the API Management service
- Consider what level of logging is necessary to meet your organization’s compliance requirements.  
- Consider how you want to secure your frontend APIs beyond using subscription keys. OAuth 2.0, OpenID Connect, and mutual TLS are common options with built-in support.
- Think about how you want to protect your backend services behind API Management. Client certificates and OAuth 2.0 are two supported options.
- Consider which client and backend protocols and ciphers are required to meet your security requirements.
- API Management validation policies are available to validate API requests and responses against an OpenAPI schema. These is not a replacement for a Web Application Firewall but can provide additional protection against some threats. Note that adding validation policies can have performance implications, so we recommend performance load tests to assess their impact on API throughput.
- Consider which identity providers besides Azure AD need to be supported.
- Consider how non-compliance should be detected.
- Consider how to standardize error responses returned by APIs.
## Design Recommendations
- Deploy a Web Application Firewall (WAF) in front of API Management to provide protection against common web application exploits and vulnerabilities. 
- Use Azure Key Vault to securely store and manage secrets and make them available through named values within API Management.
- Create a system assigned Managed Identity within API Management to establish trust relationships between the service and other resources protected by Azure Active Directory, including Key Vault and backend services.
- Use Azure built-in roles to provide least privilege permissions to manage the API Management service.
- Configure diagnostics settings within API Management to output logs and metrics to Azure Monitor.
- APIs should only be accessible over HTTPS to protect data in-transit and ensure its integrity.
- Use the latest TLS version when encrypting information in transit and disable outdated and unnecessary protocols and ciphers when possible.
- Implement an error handling policy at the global level.
- All policies should call <base/>

 
