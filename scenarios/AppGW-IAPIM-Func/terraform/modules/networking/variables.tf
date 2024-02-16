variable "workload_name" {
  type        = string
  description = "A short name for the workload being deployed"
}

variable "location" {
  type        = string
  description = ""
}

variable "deployment_environment" {
  type        = string
  description = "The environment for which the deployment is being executed"

  validation {
    condition     = contains(["dev", "uat", "prod", "dr"], var.deployment_environment)
    error_message = "Valid values for var: deployment_environment are (dev, uat, prod, dr)."
  }
}

variable "apim_cs_vnet_name_address_prefix" {
  type        = string
  description = ""
  default     = "10.2.0.0/16"
}

variable "bastion_address_prefix" {
  type        = string
  description = ""
  default     = "10.2.1.0/24"
}

variable "devops_name_address_prefix" {
  type        = string
  description = ""
  default     = "10.2.2.0/24"
}

variable "jumpbox_address_prefix" {
  type        = string
  description = ""
  default     = "10.2.3.0/24"
}

variable "appgateway_address_prefix" {
  type        = string
  description = ""
  default     = "10.2.4.0/24"
}

variable "private_endpoint_address_prefix" {
  type        = string
  description = ""
  default     = "10.2.5.0/24"
}

variable "backend_address_prefix" {
  type        = string
  description = ""
  default     = "10.2.6.0/24"
}

variable "apim_address_prefix" {
  type        = string
  description = "A short name for the PL that will be created between Funcs"
  default     = "10.2.7.0/24"
}

variable "function_id" {
  type        = string
  description = "Func id for PL to create"
  default     = "123131"
}