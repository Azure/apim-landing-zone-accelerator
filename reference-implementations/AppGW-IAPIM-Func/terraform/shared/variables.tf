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
