variable "location" {
    description = "The location of the apim instance"
    type = string
}

variable "workload_name" {
    type = string
}

variable "storage_account_tier" {
    description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
    default = "standard"
}

variable "storage_replication_type" {
  default = "LRS"
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created."
}

variable "os_type" {
  description = "A string indicating the Operating System type for this function app" 
}

variable "resource_suffix" {
  description = ""
  type        = string
}

variable "asp_tier" {
  default = "PremiumV2"
  type = string
}

variable "asp_size" {
  default = "P1v2"
  type = string
}

variable "backend_subnet_id" {
  description = "Backend resources subnet id"
  type = string
}

/* These variables are not being used, but would like to do some interpolation to have once function app resource block
variable "function_app_name" {
  type = list
  default = ["func-code", "func-cont"]
}

variable "linux_fx_version" {
  type = list
  default = ["dotnetcore|3.1","DOCKER|mcr.microsoft.com/azure-functions/dotnet"]

} */