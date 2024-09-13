variable "eventHubNamespaceName" {
  description = "The name of the Event Hub Namespace"
  type        = string
}

variable "eventHubName" {
  description = "The name of the Event Hub"
  type        = string
}

variable "eventHubSku" {
  description = "The messaging tier for Event Hub Namespace."
  type        = string
  default     = "Standard"
}

variable "apimIdentityName" {
  type = string
}

variable "apimResourceGroupName" {
  type = string
}

variable "openaiResourceGroupName" {
  type = string
}

variable "location" {
  description = "Location for all resources."
  type        = string
  default     = "eastus"
}
