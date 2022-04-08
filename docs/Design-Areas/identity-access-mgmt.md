# Identity and Access Management
## Design Considerations
- Decide on the access management for APIM services through all possible channels like portal, ARM REST API, DevOps etc.
- Decide on the access management for APIM entities.
- Decide on [how to sign up and authorize the developer accounts](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-create-or-invite-developers).
- Decide on how subscriptions are used.
- Decide on the visibility of [products](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#--products) and APIs on the developer portal using [groups](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts#--groups).
- Decide on access revocation policies.
- Decide on reporting requirements for access control.
## Design Recommendations
- Using [built-in roles](https://docs.microsoft.com/en-us/azure/api-management/api-management-role-based-access-control#built-in-roles) to control access to APIM service to delegate responsibilities across teams to manage the APIM instance.
- Using custom roles using API Management [RBAC Operations](https://docs.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations#microsoftapimanagement) to set fine-grained access to APIM entities. For example. API developers, Backup operators, DevOps Automation, etc.
- Associate subscriptions at the appropriate scope like products.
- Create appropriate [groups](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-create-groups) to control the visibility of the products.
- Manage access to the developer portal using [Azure Active Directory B2C](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-aad-b2c).
- Use [managed identity](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-use-managed-service-identity) for the APIM instance to access other Azure resources.
