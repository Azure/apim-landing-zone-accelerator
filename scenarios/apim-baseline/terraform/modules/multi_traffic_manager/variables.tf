variable "name" {
  type        = string
  description = "The traffic manager profile name"
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


variable "primaryName" {
  type        = string
  description = ""
}

variable "primaryPublicIpId" {
  type        = string
  description = ""
}

variable "secondaryName" {
  type        = string
  description = ""
}

variable "secondaryPublicIpId" {
  type        = string
  description = ""
}

variable "probe_url" {
  type        = string
  description = ""
  default     = "/status-0123456789abcdef"
}


