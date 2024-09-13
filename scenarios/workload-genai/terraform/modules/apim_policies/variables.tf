variable "resourceGroupName" {
  type        = string
  description = "The name of the resource group"
}

variable "apiManagementServiceName" {
  description = "The name of the API Management service instance"
  type        = string
}

variable "ptuDeploymentOneBaseUrl" {
  description = "The base url of the first Azure Open AI Service PTU deployment"
  type        = string
}

variable "payAsYouGoDeploymentOneBaseUrl" {
  description = "The base url of the first Azure Open AI Service Pay-As-You-Go deployment"
  type        = string
}

variable "payAsYouGoDeploymentTwoBaseUrl" {
  description = "The base url of the second Azure Open AI Service Pay-As-You-Go deployment"
  type        = string
}

variable "eventHubNamespaceName" {
  description = "The name of the Event Hub Namespace to log to"
  type        = string
}

variable "eventHubName" {
  description = "The name of the Event Hub to log utilization data to"
  type        = string
}

variable "apimIdentityName" {
  description = "The name of the API Management Identity"
  type        = string
}

variable "location" {
  description = "The location of the resource group"
  type        = string
}

variable "openaiResourceGroupName" {
  description = "The name of the resource group for the OpenAI service"
  type        = string
}
