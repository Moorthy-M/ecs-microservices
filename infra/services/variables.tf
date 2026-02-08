// Common Tags
variable "tags" {
  type = map(string)
  default = {
    "Project"     = "ecs-microservices"
    "Environment" = "learning"
  }
}

//Service Inputs

variable "services" {
  type = map(object({
    family        = string
    cpu           = number
    memory        = number
    desired_count = number

    launch_type = string
    task_role   = string

    container = object({
      name  = string
      port  = number
      image = string
    })
  }))
}
