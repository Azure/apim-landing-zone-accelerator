#-------------------------------
# Common variables
#-------------------------------
variable "resource_suffix" {
  description = ""
  type        = string
}
  
variable "location" {
    description = "The location of the apim instance"
    type = string
}

#-------------------------------
# Note: Key vault variables, needs to be updated to keep consistency
#-------------------------------
# variable "tenant_id" {
#   type        = string
#   description = ""
# }

variable "key_vault_sku"{
  type        = string
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium"
  default = "standard"
}
