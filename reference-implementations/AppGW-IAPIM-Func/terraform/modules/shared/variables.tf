#-------------------------------
# Common variables
#-------------------------------
variable "resource_suffix" {
  type = string
}

variable "location" {
  description = "The location of the apim instance"
  type        = string
}

variable "environment" {
  description = "The environment for which the deployment is being executed"
}
variable "key_vault_sku" {
  type        = string
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium"
  default     = "standard"
}

variable "bastion_host_sku" {
  description = "The SKU of the Bastion Host. Accepted values are Basic and Standard. Defaults to Basic."
  default     = "Standard"
}

variable "bastion_pip_sku" {
  description = "The SKU of the Bastion Host. Accepted values are Basic and Standard. Defaults to Basic."
  default     = "Standard"
}

variable "file_copy_enabled" {
  description = "Is File Copy feature enabled for the Bastion Host. Defaults to false."
  default     = true
}

variable "copy_paste_enabled" {
  description = "Is Copy/Paste feature enabled for the Bastion Host. Defaults to true."
  default     = true
}

variable "jumpbox_subnet_id" {
  description = "Subnet id of the bastion host"
}

variable "cicd_agent_subnet_id" {
  description = "Subnet id of the ci/cd agent"
}

variable "vm_username" {
  description = "Agent VM username"
  type        = string
}

variable "vm_password" {
  description = "Agent VM Password"
  type        = string
}

variable "cicd_agent_type" {
  type        = string
  description = "The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify 'none' if no agent needed"
}

variable "personal_access_token" {
  type        = string
  description = "Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent"
}

variable "account_name" {
  type        = string
  description = "'The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format https://dev.azure.com/ORGNAME OR github.com/ORGUSERNAME OR none'"
}

variable "pool_name" {
  type        = string
  description = "The name Azure DevOps or GitHub pool for this build agent to join. Use 'Default' if you don't have a separate pool"
}

variable "private_ip_address" {
  description = "Private ip address of the apim instance"
}

variable "apim_name" {
  description = "Resource name of the deployed internal apim instance"
}

variable "apim_vnet_id" {
  description = "APIM vnet id"
}

variable "additional_client_ids" {
  description = "List of additional clients to add to the Key Vault access policy."
  type        = list(string)
  default     = []
}