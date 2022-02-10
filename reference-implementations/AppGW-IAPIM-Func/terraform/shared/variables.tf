#-------------------------------
# Common variables
#-------------------------------
variable "workload_name" {
  description = "The name of the workload"
  type        = string
}

variable "environment" {
  description = "The environment to deploy to"
  type        = string
  default     = "dev"
}
  
variable "location" {
    description = "The location of the apim instance"
    type = string
    default = "westus2"
}

#-------------------------------
# Note: Key vault variables, needs to be updated to keep consistency
#-------------------------------

variable "tenant_id" {
  type        = string
  description = ""
}

variable "resource_group_name" {
  type        = string
  description = ""
}

variable "resource_group_location" {
  type        = string
  description = ""
}

variable "resource_suffix" {
  type        = string
  description = ""
}

variable "workload_name" {
  type        = string
  description = "A short name for the workload being deployed"
}

variable "deployment_environment" {
  type        = string
  description = "The environment for which the deployment is being executed"

validation {
condition     = contains(["dev", "uat", "prod", "dr"], var.deployment_environment)
error_message = "Valid values for var: deployment_environment are (dev, uat, prod, dr)."
} 
