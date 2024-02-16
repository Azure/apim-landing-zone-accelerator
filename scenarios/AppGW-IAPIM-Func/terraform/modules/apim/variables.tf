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
  default     = ""
}

#-------------------------------
# APIM specific variables
#-------------------------------
variable "publisher_name" {
  description = "The name of the publisher/company"
  type        = string
  default     = "Contoso"
}

variable "publisher_email" {
  description = "The email of the publisher/company; shows as administrator email in APIM"
  type        = string
  default     = "apim@contoso.com"
}

variable "sku_name" {
  description = "String consisting of two parts separated by an underscore(_). The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer_1)"
  type        = string
  default     = "Developer_1"
}

variable "apim_subnet_id" {
  description = "The subnet id of the apim instance"
  type        = string
}

variable "workspace_id" {
  type        = string
  description = "The workspace id of the log analytics workspace"
}

variable "instrumentation_key" {
  type        = string
  description = "App insights instrumentation key"
}