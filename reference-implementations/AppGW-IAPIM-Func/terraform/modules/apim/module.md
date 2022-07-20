# apim

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
| [azurerm_api_management.apim_internal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management) | resource |
| [azurerm_api_management_diagnostic.apim_diagnostic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_diagnostic) | resource |
| [azurerm_api_management_logger.apim_logger](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_logger) | resource |
| [azurerm_resource_group.apim_internal_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apim_subnet_id"></a> [apim\_subnet\_id](#input\_apim\_subnet\_id) | The subnet id of the apim instance | `string` | n/a | yes |
| <a name="input_instrumentation_key"></a> [instrumentation\_key](#input\_instrumentation\_key) | App insights instrumentation key | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location of the apim instance | `string` | `""` | no |
| <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email) | The email of the publisher/company | `string` | `"apim@contoso.com"` | no |
| <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name) | The name of the publisher/company | `string` | `"Contoso"` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | ------------------------------- Common variables ------------------------------- | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | String consisting of two parts separated by an underscore(\_). The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer\_1) | `string` | `"Developer_1"` | no |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | The workspace id of the log analytics workspace | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apim_id"></a> [apim\_id](#output\_apim\_id) | The resource id of the apim instance |
| <a name="output_apim_name"></a> [apim\_name](#output\_apim\_name) | The resource name of the apim instance |
| <a name="output_apim_resource_group_location"></a> [apim\_resource\_group\_location](#output\_apim\_resource\_group\_location) | The resource group location of the apim instance |
| <a name="output_apim_resource_group_name"></a> [apim\_resource\_group\_name](#output\_apim\_resource\_group\_name) | The resource group name of the apim instance |
| <a name="output_name"></a> [name](#output\_name) | The name of the apim instance |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | Used to connect from within the network to API Management endpoints |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
