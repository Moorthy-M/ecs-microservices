// Common Tags
variable "tags" {
  type = map(string)
  default = {
    "Project"     = "ecs-microservices"
    "Environment" = "learning"
  }
}

// OIDC ARN
variable "oidc_arn" {
  type        = string
  description = "OIDC ARN for CI/CD roles"
}
