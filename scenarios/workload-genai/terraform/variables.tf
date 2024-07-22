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

variable "environment" {
  type        = string
  description = "Environment"
  default     = "dev"
}

variable "identifier" {
  description = "The identifier for the resource deployments"
  type        = string
}

variable "tags" {
  description = "(Optional) Specifies tags for all the resources"
  default     = {}
}

variable "log_analytics_workspace_name" {
  description = "Specifies the name of the log analytics workspace"
  default     = "Workspace"
  type        = string
}

variable "vnet_name" {
  description = "Specifies the name of the virtual network"
  default     = "VNet"
  type        = string
}

variable "vnet_address_space" {
  description = "Specifies the address prefix of the virtual network"
  default     = ["10.0.0.0/16"]
  type        = list(string)
}

variable "privateEndpointAddressPrefix" {
  description = "Private Endpoint Address Prefix"
  type        = string
  default     = "10.2.5.0/24"
}

variable "internal_load_balancer_enabled" {
  description = "(Optional) specifies whether the Azure Container Apps Environment operate in Internal Load Balancing Mode? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "openai_name" {
  description = "(Required) Specifies the name of the Azure OpenAI Service"
  type        = string
  default     = "OpenAI"
}

variable "openai_sku_name" {
  description = "(Optional) Specifies the sku name for the Azure OpenAI Service"
  type        = string
  default     = "S0"
}

variable "openai_custom_subdomain_name" {
  description = "(Optional) Specifies the custom subdomain name of the Azure OpenAI Service"
  type        = string
  nullable    = true
  default     = ""
}

variable "openai_public_network_access_enabled" {
  description = "(Optional) Specifies whether public network access is allowed for the Azure OpenAI Service"
  type        = bool
  default     = false
}

variable "openai_deployments" {
  description = "(Optional) Specifies the deployments of the Azure OpenAI Service"
  type = list(object({
    name = string
    model = object({
      name    = string
      version = string
    })
    rai_policy_name = string
  }))
  default = [
    {
      name = "gpt-35-turbo-16k"
      model = {
        name    = "gpt-35-turbo-16k"
        version = "0613"
      }
      rai_policy_name = ""
    },
    {
      name = "text-embedding-ada-002"
      model = {
        name    = "text-embedding-ada-002"
        version = "2"
      }
      rai_policy_name = ""
    }
  ]
}

variable "workload_managed_identity_name" {
  description = "(Required) Specifies the name of the workload user-defined managed identity"
  type        = string
  default     = "WorkloadIdentity"
}

variable "eventHubName" {
  description = "The name of the Event Hub to log utilization data to"
  type        = string
  default     = "apim-utilization-reporting"
}

variable "apimIdentityName" {
  description = "The name of the API Management Identity"
  type        = string
  default     = "apimIdentity"
}
