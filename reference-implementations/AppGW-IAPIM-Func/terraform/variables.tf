variable "workload_name" {
   # default = "pr-workload"
    description = "The name of the workload"
    type = string
  
}

variable "environment" {
    description = "The environment to deploy to"
    type = string
  
}

variable "location" {
    description = "The location to deploy to"
    type = string
}