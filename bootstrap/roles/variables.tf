// Common Tags
variable "tags" {
  type = map(string)
  default = {
    "Project"     = "ecs-microservices"
    "Environment" = "learning"
  }
}

// State Bucket ARN
variable "tf_state_bucket_arn" {
  type = string
  description = "State Bucket ARN for Permission Policy"
}

// OIDC ARN
variable "oidc_arn" {
  type = string
  description = "OIDC ARN for CI/CD roles"
}

// OIDC CI Trust JSON Document
variable "ci_trust" {
  type = string
  description = "OIDC trust policy JSON for CI roles"
}

// OIDC CD Trust JSON Document
variable "cd_trust" {
  type = string
  description = "OIDC trust policy JSON for CI roles"
}
