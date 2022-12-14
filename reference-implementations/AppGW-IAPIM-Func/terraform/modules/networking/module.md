# networking

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
| [azurerm_bastion_host.bastion_host](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_network_security_group.apim_snnsg_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.appgateway_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.backend_snnsg_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.bastion_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.devops_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.jumpbox_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.private_endpoint_snnsg_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.bastion_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.networking_resourece_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_network.apim_cs_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apim_address_prefix"></a> [apim\_address\_prefix](#input\_apim\_address\_prefix) | A short name for the PL that will be created between Funcs | `string` | `"10.2.7.0/24"` | no |
| <a name="input_apim_cs_vnet_name_address_prefix"></a> [apim\_cs\_vnet\_name\_address\_prefix](#input\_apim\_cs\_vnet\_name\_address\_prefix) | n/a | `string` | `"10.2.0.0/16"` | no |
| <a name="input_appgateway_address_prefix"></a> [appgateway\_address\_prefix](#input\_appgateway\_address\_prefix) | n/a | `string` | `"10.2.4.0/24"` | no |
| <a name="input_backend_address_prefix"></a> [backend\_address\_prefix](#input\_backend\_address\_prefix) | n/a | `string` | `"10.2.6.0/24"` | no |
| <a name="input_bastion_address_prefix"></a> [bastion\_address\_prefix](#input\_bastion\_address\_prefix) | n/a | `string` | `"10.2.1.0/24"` | no |
| <a name="input_deployment_environment"></a> [deployment\_environment](#input\_deployment\_environment) | The environment for which the deployment is being executed | `string` | n/a | yes |
| <a name="input_devops_name_address_prefix"></a> [devops\_name\_address\_prefix](#input\_devops\_name\_address\_prefix) | n/a | `string` | `"10.2.2.0/24"` | no |
| <a name="input_function_id"></a> [function\_id](#input\_function\_id) | Func id for PL to create | `string` | `"123131"` | no |
| <a name="input_jumpbox_address_prefix"></a> [jumpbox\_address\_prefix](#input\_jumpbox\_address\_prefix) | n/a | `string` | `"10.2.3.0/24"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_private_endpoint_address_prefix"></a> [private\_endpoint\_address\_prefix](#input\_private\_endpoint\_address\_prefix) | n/a | `string` | `"10.2.5.0/24"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | A short name for the workload being deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apim_cs_vnet_id"></a> [apim\_cs\_vnet\_id](#output\_apim\_cs\_vnet\_id) | n/a |
| <a name="output_apim_cs_vnet_name"></a> [apim\_cs\_vnet\_name](#output\_apim\_cs\_vnet\_name) | n/a |
| <a name="output_apim_subnet_id"></a> [apim\_subnet\_id](#output\_apim\_subnet\_id) | n/a |
| <a name="output_apim_subnet_name"></a> [apim\_subnet\_name](#output\_apim\_subnet\_name) | n/a |
| <a name="output_appgateway_subnet_id"></a> [appgateway\_subnet\_id](#output\_appgateway\_subnet\_id) | n/a |
| <a name="output_appgateway_subnet_name"></a> [appgateway\_subnet\_name](#output\_appgateway\_subnet\_name) | n/a |
| <a name="output_backend_subnet_id"></a> [backend\_subnet\_id](#output\_backend\_subnet\_id) | n/a |
| <a name="output_backend_subnet_name"></a> [backend\_subnet\_name](#output\_backend\_subnet\_name) | n/a |
| <a name="output_bastion_subnet_id"></a> [bastion\_subnet\_id](#output\_bastion\_subnet\_id) | n/a |
| <a name="output_bastion_subnet_name"></a> [bastion\_subnet\_name](#output\_bastion\_subnet\_name) | n/a |
| <a name="output_cicd_agent_subnet_id"></a> [cicd\_agent\_subnet\_id](#output\_cicd\_agent\_subnet\_id) | n/a |
| <a name="output_devops_subnet_name"></a> [devops\_subnet\_name](#output\_devops\_subnet\_name) | n/a |
| <a name="output_jumpbox_subnet_id"></a> [jumpbox\_subnet\_id](#output\_jumpbox\_subnet\_id) | n/a |
| <a name="output_jumpbox_subnet_name"></a> [jumpbox\_subnet\_name](#output\_jumpbox\_subnet\_name) | n/a |
| <a name="output_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#output\_private\_endpoint\_subnet\_id) | n/a |
| <a name="output_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#output\_private\_endpoint\_subnet\_name) | n/a |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
