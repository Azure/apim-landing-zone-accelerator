# gateway

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_key_vault_access_policy.user_assigned_identity_keyvault_permissions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_certificate.kv_domain_certs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) | resource |
| [azurerm_key_vault_certificate.local_domain_certs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) | resource |
| [azurerm_public_ip.public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_user_assigned_identity.user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_gateway_certificate_type"></a> [app\_gateway\_certificate\_type](#input\_app\_gateway\_certificate\_type) | The certificate type used for the app gateway. Either custom or selfsigned | `string` | n/a | yes |
| <a name="input_certificate_password"></a> [certificate\_password](#input\_certificate\_password) | n/a | `string` | n/a | yes |
| <a name="input_certificate_path"></a> [certificate\_path](#input\_certificate\_path) | n/a | `string` | `null` | no |
| <a name="input_fqdn"></a> [fqdn](#input\_fqdn) | n/a | `string` | `"api.example.com"` | no |
| <a name="input_keyvault_id"></a> [keyvault\_id](#input\_keyvault\_id) | n/a | `string` | `null` | no |
| <a name="input_primary_backendend_fqdn"></a> [primary\_backendend\_fqdn](#input\_primary\_backendend\_fqdn) | n/a | `string` | `"api-internal.example.com"` | no |
| <a name="input_probe_url"></a> [probe\_url](#input\_probe\_url) | n/a | `string` | `"/status-0123456789abcdef"` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | n/a | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | n/a | `string` | n/a | yes |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | n/a | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Resource ID for the provisioned Application Gateway. |
| <a name="output_pip_address"></a> [pip\_address](#output\_pip\_address) | Resource ID for the Application Gateway associated Public IP. |
| <a name="output_pip_id"></a> [pip\_id](#output\_pip\_id) | Resource ID for the Application Gateway associated Public IP. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
