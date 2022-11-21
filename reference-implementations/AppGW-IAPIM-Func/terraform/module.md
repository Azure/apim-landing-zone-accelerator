# terraform

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | =2.95.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apim"></a> [apim](#module\_apim) | ./modules/apim | n/a |
| <a name="module_application_gateway"></a> [application\_gateway](#module\_application\_gateway) | ./modules/gateway | n/a |
| <a name="module_backend"></a> [backend](#module\_backend) | ./modules/backend | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |
| <a name="module_resource_suffix"></a> [resource\_suffix](#module\_resource\_suffix) | ./modules/service-suffix | n/a |
| <a name="module_shared"></a> [shared](#module\_shared) | ./modules/shared | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format https://dev.azure.com/ORGNAME OR github.com/ORGUSERNAME OR none | `string` | n/a | yes |
| <a name="input_apim_name"></a> [apim\_name](#input\_apim\_name) | n/a | `string` | `"apim.contoso.com"` | no |
| <a name="input_app_gateway_certificate_type"></a> [app\_gateway\_certificate\_type](#input\_app\_gateway\_certificate\_type) | The certificate type used for the app gateway. Either custom or selfsigned | `string` | `"custom"` | no |
| <a name="input_app_gateway_fqdn"></a> [app\_gateway\_fqdn](#input\_app\_gateway\_fqdn) | n/a | `string` | `"api.contoso.com"` | no |
| <a name="input_certificate_password"></a> [certificate\_password](#input\_certificate\_password) | n/a | `string` | `null` | no |
| <a name="input_certificate_path"></a> [certificate\_path](#input\_certificate\_path) | n/a | `string` | `null` | no |
| <a name="input_certificate_secret_name"></a> [certificate\_secret\_name](#input\_certificate\_secret\_name) | n/a | `string` | `null` | no |
| <a name="input_cicd_agent_type"></a> [cicd\_agent\_type](#input\_cicd\_agent\_type) | The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify 'none' if no agent needed') | `string` | n/a | yes |
| <a name="input_deployment_environment"></a> [deployment\_environment](#input\_deployment\_environment) | The environment for which the deployment is being executed | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location in which the deployment is happening | `string` | `"East US"` | no |
| <a name="input_personal_access_token"></a> [personal\_access\_token](#input\_personal\_access\_token) | Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent | `string` | n/a | yes |
| <a name="input_pool_name"></a> [pool\_name](#input\_pool\_name) | The name Azure DevOps or GitHub pool for this build agent to join. Use 'Default' if you don't have a separate pool | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | n/a | `string` | `"001"` | no |
| <a name="input_vm_password"></a> [vm\_password](#input\_vm\_password) | Agent VM Password | `string` | n/a | yes |
| <a name="input_vm_username"></a> [vm\_username](#input\_vm\_username) | Agnet VM username | `string` | n/a | yes |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | A short name for the workload being deployed | `string` | `"proy"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
