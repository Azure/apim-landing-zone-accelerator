# Scenario 1: Azure API Management - Secure Baseline

This reference implementation demonstrates a *secure baseline infrastructure architecture* for provisioning [Azure API Management](https://learn.microsoft.com/azure/api-management/). Specifically this scenario addresses deploying Azure Container Apps into a [virtual network](https://learn.microsoft.com/en-us/azure/api-management/api-management-using-with-internal-vnet?tabs=stv2), in an internal mode where you can only access the API Management endpoints like API gateway, developer portal, Direct management and Git within a VNet whose access you control.

By the end of this deployment guide, you would have deployed an "internal mode" Azure API Management premium instance. 

![Architectural diagram showing an Azure API Management deployment in a virtual network.](../../docs/images/apim-secure-baseline.jpg)

## Core architecture components

- Azure API Management (Premium)
- Azure Virtual Networks
- Azure Application Gateway (with Web Application Firewall)
- Azure Standard Public IP (with [DDoS protection](https://learn.microsoft.com/azure/ddos-protection/ddos-protection-sku-comparison#skus))
- Azure Key Vault
- Azure Private Endpoint
- Azure Private DNS Zones
- Log Analytics Workspace
- Azure Application Insights

All resources have enabled their Diagnostics Settings (by default sending the logs to a Log Analytics Workspace).

All the resources that support Zone Redundancy (i.e. Container Apps Environment, Application Gateway, Standard IP) are set by default to be deployed in all Availability Zones. If you are planning to deploy to a region that is not supporting Availability Zones you need to set the  parameter  `deployZoneRedundantResources` to `false`. 

## Deploy the reference implementation

This reference implementation is provided with the following infrastructure as code options. 
@seenu433 - please update