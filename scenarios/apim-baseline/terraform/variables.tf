variable "location" {
  type        = string
  description = "The Azure location in which the deployment is happening"
  default     = "eastus"
}

variable "workloadName" {
  type        = string
  description = "A suffix for naming"
  default     = "apimdemo"
}

variable "appGatewayFqdn" {
  type        = string
  description = "The Azure location to deploy to"
  default     = "apim.example.com"
}

variable "appGatewayCertType" {
  type        = string
  description = "selfsigned will create a self-signed certificate for the APPGATEWAY_FQDN. custom will use an existing certificate in pfx format that needs to be available in the [certs](../../certs) folder and named appgw.pfx "
  default     = "selfsigned"
}

variable "environment" {
  type        = string
  description = "Environment"
  default     = "dev"
}

variable "apimCSVNetNameAddressPrefix" {
  description = "APIM CSV Net Name Address Prefix"
  type        = string
  default     = "10.2.0.0/16"
}

variable "appGatewayAddressPrefix" {
  description = "App Gateway Address Prefix"
  type        = string
  default     = "10.2.4.0/24"
}

variable "apimAddressPrefix" {
  description = "APIM Address Prefix"
  type        = string
  default     = "10.2.7.0/24"
}

variable "privateEndpointAddressPrefix" {
  description = "Private Endpoint Address Prefix"
  type        = string
  default     = "10.2.5.0/24"
}

variable "deploymentAddressPrefix" {
  description = "Deployment Address Prefix"
  type        = string
  default     = "10.2.8.0/24"
}




