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

variable "apimCSVNetNameAddressPrefix" {
  description = "APIM CSV Net Name Address Prefix"
  type        = string
}

variable "appGatewayAddressPrefix" {
  description = "App Gateway Address Prefix"
  type        = string
}

variable "apimAddressPrefix" {
  description = "APIM Address Prefix"
  type        = string
}

variable "privateEndpointAddressPrefix" {
  description = "Private Endpoint Address Prefix"
  type        = string
}

variable "deploymentAddressPrefix" {
  description = "Deployment Address Prefix"
  type        = string
}


