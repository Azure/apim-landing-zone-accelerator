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

variable "apimName" {
  type        = string
  description = "The name of the API Management instance"
}

variable "apimPrivateIp" {
  type        = string
  description = "The private IP address of the API Management instance"
}

variable "apimVnetId" {
  type = string
}












