variable "location" {
  type        = string
  description = "The Azure location in which the deployment is happening"
  default     = "eastus"
}

variable "resourceSuffix" {
  type        = string
  description = "A suffix for naming"
}

variable "environment" {
  type        = string
  description = "Environment"
  default     = "dev"
}

variable "resourceGroupName" {
  type        = string
  description = "The name of the resource group"
}

variable "keyVaultName" {
  type        = string
  description = "The name of the Key Vault"
}

variable "keyVaultSku" {
  type        = string
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium"
  default     = "standard"
}

variable "additionalClientIds" {
  description = "List of additional clients to add to the Key Vault access policy."
  type        = list(string)
  default     = []
}

variable "deploymentSubnetId" {
  type = string
}

variable "storage_account_name" {
  type = string
}
