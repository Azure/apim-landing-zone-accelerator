#-------------------------------
# Common variables
#-------------------------------
variable "resource_suffix" {
  description = ""
  type        = string
}
  
variable "location" {
    description = "The location of the apim instance"
    type        = string
}

variable "environment" {
  description = "The environment for which the deployment is being executed"
}
variable "key_vault_sku"{
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
  description = ""
  type = string
  default = ""

}

variable "vm_password" {
  description = ""
  type = string
  default = ""
}

variable "cicd_agent_type" {
  type = string
  description = ""
  default = ""
}

variable "personal_access_token" {
  type = string
  default = ""
}

variable "account_name" {
  type = string
  default = ""
  description = ""
}

variable "pool_name" {
  type = string
  default = ""
  description = ""
  
}

variable "private_ip_address" {
  default = ""
  description = "Private ip address of the apim instance"
}

variable "apim_name" {
  description = "Resource name of the deployed internal apim instance"
}