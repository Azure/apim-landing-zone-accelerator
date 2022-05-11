# Management and Monitoring

## Design Considerations

- Be aware of maximum[throughput limits](https://azure.microsoft.com/en-us/pricing/details/api-management/) of each APIM SKU
- Be aware of the maximum number of [scale-out units](https://azure.microsoft.com/en-us/pricing/details/api-management/) per APIM SKU
- Be aware of the maximum throughputs are approximate and not guarantees
- Be aware of the time required to scale-out, deploy into another region, or convert from deployment types
- Consider the number of service units required through [configuration](https://docs.microsoft.com/en-us/azure/api-management/upgrade-and-scale#scale-your-api-management-service) or [auto-scaling](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-autoscale)
- APIM does not scale-out automatically, additional configuration is required.
- There is no downtime during a scale-out event
- Only the gateway component of API Management is deployed to all regions in a multi-region deployment.
- Be aware of the possible performance impact of AppInsights logging at high loads.
- Be aware that the number of inbound and outbound policies applied and their impact to performance
- Consider using policies for [access restriction](https://docs.microsoft.com/en-us/azure/api-management/api-management-access-restriction-policies#AccessRestrictionPolicies), [authentication](https://docs.microsoft.com/en-us/azure/api-management/api-management-authentication-policies#AuthenticationPolicies), [caching](https://docs.microsoft.com/en-us/azure/api-management/api-management-caching-policies#CachingPolicies), [cross domain](https://docs.microsoft.com/en-us/azure/api-management/api-management-cross-domain-policies#CrossDomainPolicies), [transformation](https://docs.microsoft.com/en-us/azure/api-management/api-management-transformation-policies#TransformationPolicies), [Dapr integration](https://docs.microsoft.com/en-us/azure/api-management/api-management-dapr-policies), and [validation](https://docs.microsoft.com/en-us/azure/api-management/validation-policies)
- Policies are code and should be under version control
- APIM's built-in cache is shared by all units in the same region in the same API Management service.
- Utilize [Availability Zones](https://docs.microsoft.com/en-us/azure/api-management/zone-redundancy), the number of Units selected must distribute evenly across the zones
- Self-hosted gateway's credentials expire every 30 days and must be rotated.
- The Uri /status-0123456789abcdef can be used as a common health endpoint for the APIM service.
- The APIM Service is not a WAF. Deploy Azure App Gateway in front to add additional layers of protection
- Client certificate negotiation is enabled is a per-gateway configuration
- Certificates updated in the key vault are automatically rotated in API Management and is updated within 4 hours.
- Secret in Key Vault is updated within 4 hours after being set. You can also manually refresh the secret using the Azure portal or via the management REST API.
- [Custom Domains](https://docs.microsoft.com/en-us/azure/api-management/configure-custom-domain) can be applied to all endpoints or just a subset. The Premium tier supports setting multiple host names for the Gateway endpoint.
- APIM can be backed up using its Management REST API. Backups expire after 30 days. Be aware of what APIM does not back up.
- [Named values](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-properties?tabs=azure-portal) are global in scope.
- API Operations can be grouped into [Products](https://docs.microsoft.com/en-us/azure/api-management/api-management-terminology#term-definitions) and Subscriptions. The design will be based on actual business requirements.

## Design Recommendations

- Apply custom domains to the Gateway endpoint only
- Use [Event Hub policy](https://docs.microsoft.com/en-us/azure/api-management/api-management-log-to-eventhub-sample) for logging at high performance levels
- Utilize an [external cache](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-cache-external) for control and fastest performance
- Deploy at least two scale units spread over two AZs per region for best availability and performance
- Utilize Azure Monitor to Autoscale APIM. If using a self-hosted gateway, use Kubernetes Horizonal Pod Autoscaler to scale out the gateway
- Deploy self-host gateways where Azure does not have a region close to the back-end API
- Utilize Key Vault for Certificate storage, notification, and rotation
- Do not enable 3DES, TLS1.1 or lower encryption protocols unless absolutely required.
- Utilize DevOps and Infrastructure-As-Code practices to handle all deployments, updates, and DR.
- Create an API revision and Change Log entry for every API update.
- Utilize [Backends](https://docs.microsoft.com/en-us/azure/api-management/backends) to eliminate redundant API backend configurations.
- Utilize[ Named-Values](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-properties?tabs=azure-portal#add-or-edit-a-named-value) to store common values that can be used in policies.
- Utilize Key Vault to store secrets that Named-Values can reference.
- Secrets updated in the key vault are automatically rotated in API Management.
- Develop communication strategy to notify users of breaking API version update.
- Set diagnostic settings to forward AllMetrics and AllLogs to Log Analytics workspace
- Reporting
  - Make use of [built-in analytics](https://docs.microsoft.com/en-us/azure/api-management/howto-use-analytics)
  - Review Audit logs
  - Create custom reports
  - Configure [cloud logs for self-hosted gateway](https://docs.microsoft.com/en-us/azure/api-management/how-to-configure-local-metrics-logs) or [local logs for self-hosted gateway on Kubernetes clusters](https://docs.microsoft.com/en-us/azure/api-management/how-to-configure-local-metrics-logs)
