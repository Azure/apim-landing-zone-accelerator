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

#-------------------------------
# APIM specific variables
#-------------------------------

variable "keyVaultName" {
  description = "The name of the Key Vault"
  type        = string
}

variable "publisherName" {
  description = "The name of the publisher/company"
  type        = string
  default     = "Contoso"
}

variable "publisherEmail" {
  description = "The email of the publisher/company; shows as administrator email in APIM"
  type        = string
  default     = "apim@contoso.com"
}

variable "skuName" {
  description = "String consisting of two parts separated by an underscore(_). The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer_1)"
  type        = string
  default     = "Developer_1"
}

variable "apimSubnetId" {
  description = "The subnet id of the apim instance"
  type        = string
}

variable "workspaceId" {
  type        = string
  description = "The workspace id of the log analytics workspace"
}

variable "instrumentationKey" {
  type        = string
  description = "App insights instrumentation key"
}

variable "sharedResourceGroupName" {
  type        = string
  description = "The name of the shared resource group"
}
