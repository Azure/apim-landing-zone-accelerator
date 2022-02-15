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
}

variable "certificate_path" {
  type        = string
  description = ""
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