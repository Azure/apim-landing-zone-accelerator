variable "workload_name" {
  type        = string
  description = "A short name for the workload being deployed"
  default     = "proy"
  validation {
    condition = (
      can(regex("^[a-zA-Z0-9]{3,8}$", var.workload_name))
    )
    error_message = "Please enter a valid value (alphanumberic no spaces less than 8 chars)."
  }
}

variable "deployment_environment" {
  type        = string
  description = "The environment for which the deployment is being executed"
  default     = "dev"

  validation {
    condition     = contains(["dev", "uat", "prod", "dr"], var.deployment_environment)
    error_message = "Valid values for var: deployment_environment are (dev, uat, prod, dr)."
  }
}

variable "location" {
  type        = string
  description = "The location in which the deployment is happening"
  default     = "East US"
  validation {
    condition = anytrue([
      var.location == "East US",
      var.location == "West US"
    ])
    error_message = "Please enter a valid Azure Region."
  }
}

variable "resource_suffix" {
  type        = string
  description = ""
  default     = "001"
}

variable "apim_name" {
  type        = string
  description = ""
  default     = "apim.contoso.com"
}

variable "app_gateway_fqdn" {
  type        = string
  description = ""
  default     = "api.contoso.com"
}

variable "certificate_path" {
  type        = string
  description = ""
  default     = null
}

variable "certificate_password" {
  type        = string
  description = ""
  default     = null
}

variable "certificate_secret_name" {
  type        = string
  description = ""
  default     = null
}

variable "app_gateway_certificate_type" {
  type        = string
  description = "The certificate type used for the app gateway. Either custom or selfsigned"
  default     = "selfsigned"
  # To do change this to key vault or imported not self documenting
  validation {
    condition     = contains(["custom", "selfsigned"], var.app_gateway_certificate_type)
    error_message = "Valid values for var: app_gateway_certificate_type are (custom, selfsigned)."
  }
}

# Backend resource variables
variable "vm_username" {
  type        = string
  description = "Agent VM username"
}

variable "vm_password" {
  description = "Agent VM Password"
  type        = string
  sensitive   = true
}

variable "cicd_agent_type" {
  type        = string
  description = "The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify 'none' if no agent needed')"
  default     = "none"
  validation {
    condition     = contains(["azuredevops", "github", "none"], var.cicd_agent_type)
    error_message = "Valid values for var: deployment_environment are (azuredevops, github, none)."
  }
}

variable "personal_access_token" {
  type        = string
  description = "Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent"
  sensitive   = true
}

variable "account_name" {
  type        = string
  description = "The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format https://dev.azure.com/ORGNAME OR github.com/ORGUSERNAME OR none"
  default     = "none"
}

variable "pool_name" {
  type        = string
  description = "The name Azure DevOps or GitHub pool for this build agent to join. Use 'Default' if you don't have a separate pool"
  default     = "default"
}

variable "cicd_spn_client_id" {
  description = "Deployment service principal client ID for CICD agent to grant access to shared key vault."
  type        = string
  default     = null
}