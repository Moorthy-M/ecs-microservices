// Common Tags
variable "tags" {
  type = map(string)
  default = {
    "Project"     = "ecs-microservices"
    "Environment" = "learning"
  }
}

variable "db_identifier" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_allocatted_storage" {
  type = number
}

variable "db_storage_type" {
  type = string
}

variable "db_multi_az" {
  type = bool
}

variable "db_deletion_protection" {
  type = bool
}

variable "db_skip_final_snapshot" {
  type = bool
}

variable "db_backup_retention_period" {
  type = number
}
