variable "name" {
  description = "(Required) Specifies the name of the private dns zone"
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the resource group name of the private dns zone"
  type        = string
}

variable "tags" {
  description = "(Optional) Specifies the tags of the private dns zone"
  default     = {}
}

variable "virtual_networks_to_link_id" {
  description = "(Optional) Specifies the virtual networks id to which create a virtual network link"
  type        = string
}

variable "second_virtual_networks_to_link_id" {
  description = "(Optional) Specifies the virtual networks id to which create a virtual network link"
  type        = string
  default     = null
}

variable "multiRegionEnabled" {
  description = "(Optional) Specifies if the multi-region is enabled"
  type        = bool
  default     = false
}

