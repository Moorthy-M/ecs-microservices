// Common Tags
variable "tags" {
  type = map(string)
  default = {
    "Project"     = "ecs-microservices"
    "Environment" = "learning"
  }
}

// Application Load Balancer
variable "alb_name" {
  type = string
}

variable "alb_internal" {
  type    = bool
  default = false
}

variable "enable_deletion_protection" {
  type    = bool
  default = true
}

variable "alb_sg_ingress_rules" {
  type = list(object(
    {
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
      description     = optional(string, "")
    }
  ))
}

variable "alb_sg_egress_rules" {
  type = list(object(
    {
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
      description     = optional(string, "")
    }
  ))
}

variable "alb_target_port" {
  type = number
}

variable "alb_target_protocol" {
  type = string
}

variable "alb_target_type" {
  type = string
}

variable "health_check_path" {
  type = string
}

variable "health_check_protocol" {
  type = string
}

variable "health_check_matcher" {
  type = string
}

variable "health_check_interval" {
  type = number
}

variable "health_check_timeout" {
  type = number
}