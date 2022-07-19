variable "resource_group_name" {
  type        = string
  description = ""
}

variable "resource_group_location" {
  type        = string
  description = ""
}

variable "secret_name" {
  type        = string
  description = ""
}

variable "keyvault_id" {
  type        = string
  description = ""
  default     = null
}

variable "app_gateway_certificate_type" {
  type        = string
  description = "The certificate type used for the app gateway. Either custom or selfsigned"
}

variable "certificate_path" {
  type        = string
  description = ""
  default     = null
}

variable "certificate_password" {
  type        = string
  description = ""
}

variable "resource_suffix" {
  type        = string
  description = ""
}

variable "fqdn" {
  type        = string
  description = ""
  default     = "api.example.com"
}

variable "primary_backendend_fqdn" {
  type        = string
  description = ""
  default     = "api-internal.example.com"
}

variable "probe_url" {
  type        = string
  description = ""
  default     = "/status-0123456789abcdef"
}

variable "subnet_id" {
  type        = string
  description = ""
}