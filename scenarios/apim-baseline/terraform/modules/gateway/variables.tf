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

variable "appGatewayCertType" {
  description = "selfsigned will create a self-signed certificate for the APPGATEWAY_FQDN. custom will use an existing certificate in pfx format that needs to be available in the [certs](../../certs) folder and named appgw.pfx "
  default     = "selfsigned"
}

variable "keyvaultId" {
  type        = string
  description = ""
  default     = null
}

variable "appGatewayFqdn" {
  type        = string
  description = "The Azure location to deploy to"
  default     = "apim.example.com"
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

variable "subnetId" {
  type        = string
  description = ""
}

variable "primaryBackendendFqdn" {
  type        = string
  description = ""
}

variable "probe_url" {
  type        = string
  description = ""
  default     = "/status-0123456789abcdef"
}




