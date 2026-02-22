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
    launch_type   = string

    task_role = string

    alb = object({
      health_path = string
      route_path  = string
      protocol    = string
      priority    = number
    })

    container = object({
      name    = string
      port    = number
      image   = string
      secrets = optional(bool, false)
    })
  }))
}
