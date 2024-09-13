variable "location" {
  type        = string
  description = "The Azure location in which the deployment is happening"
  default     = "eastus2"
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

variable "keyVaultSku" {
  type        = string
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium"
  default     = "standard"
}

variable "additionalClientIds" {
  description = "List of additional clients to add to the Key Vault access policy."
  type        = list(string)
  default     = []
}

variable "certificatePassword" {
  description = "Password for the certificate"
  type        = string
  default     = ""
}

variable "certificatePath" {
  description = "Path to the certificate"
  type        = string
  default     = "../../certs/appgw.pfx"
}

variable "identifier" {
  description = "The identifier for the resource deployments"
  type        = string
}
