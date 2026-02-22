// Import Network Stack
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-moorthy-terraform-state"
    key    = "Network/terraform.tfstate"
    region = "ap-south-1"
  }
}

module "main_db" {

  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//database?ref=v1.0.2"

  db_identifier = var.db_identifier
  db_name       = var.db_name
  db_user_name  = var.db_username

  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocatted_storage
  db_storage_type      = var.db_storage_type

  db_multi_az                = var.db_multi_az
  db_deletion_protection     = var.db_deletion_protection
  db_backup_retention_period = var.db_backup_retention_period
  db_skip_final_snapshot     = var.db_skip_final_snapshot

  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  db_subnets = flatten(values(data.terraform_remote_state.network.outputs.private_db_subnets_by_az))

  tags = var.tags
}