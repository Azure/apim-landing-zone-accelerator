variable "location" {
  description = "The location of the apim instance"
  type        = string
}

variable "workload_name" {
  type        = string
  description = ""
}

variable "storage_account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are 'Standard' and 'Premium'. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
  default     = "Standard"
}

variable "storage_replication_type" {
  default     = "LRS"
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created."
}

variable "resource_suffix" {
  description = ""
  type        = string
}

variable "sp_sku" {
  default = "P1v2"
  type    = string
}

variable "backend_subnet_id" {
  description = "Backend resources subnet id"
  type        = string
}