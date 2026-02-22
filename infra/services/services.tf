data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "s3-moorthy-terraform-state"
    key    = "Network/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "bootstrap" {
  backend = "s3"

  config = {
    bucket = "s3-moorthy-terraform-state"
    key    = "ecs-microservices/bootstrap/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "platform" {
  backend = "s3"

  config = {
    bucket = "s3-moorthy-terraform-state"
    key    = "ecs-microservices/platform/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"

  config = {
    bucket = "s3-moorthy-terraform-state"
    key    = "ecs-microservices/database/terraform.tfstate"
    region = "ap-south-1"
  }
}

locals {
  default = {
    host = ""
    port = -1
    name = ""
  }
}

resource "aws_security_group_rule" "db_ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.database.outputs.security_group
  source_security_group_id = module.services["authentication"].service_sg_id
}

module "services" {
  for_each = var.services

  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//ecs?ref=v1.0.3"

  cluster_name = data.terraform_remote_state.platform.outputs.ecs_cluster_name
  cluster_id = data.terraform_remote_state.platform.outputs.ecs_cluster_id

  service_name          = each.key
  service_desired_count = each.value.desired_count
  service_launch_type   = each.value.launch_type

  task_definition_family = each.value.family
  task_definition_cpu    = each.value.cpu
  task_definition_memory = each.value.memory

  execution_role_arn = data.terraform_remote_state.bootstrap.outputs.ecs_execution_role_arn
  task_role_arn      = data.terraform_remote_state.bootstrap.outputs.ecs_task_role_arns[each.value.task_role]

  container = each.value.container

  db_secrets_arn = each.value.container.secrets ? data.terraform_remote_state.database.outputs.db_secret_arn : ""
  db_environments = each.value.container.secrets ? {
    host = split(":", data.terraform_remote_state.database.outputs.rds_endpoint)[0]
    port = split(":", data.terraform_remote_state.database.outputs.rds_endpoint)[1]
    name = data.terraform_remote_state.database.outputs.db_name
  } : local.default

  network = {
    vpc             = data.terraform_remote_state.network.outputs.vpc_id
    subnets         = data.terraform_remote_state.network.outputs.private_app_subnets
    security_groups = [data.terraform_remote_state.platform.outputs.alb_sg_id]
  }

  alb = merge(each.value.alb, {
    listener_arn = data.terraform_remote_state.platform.outputs.alb_listener_arn
  })

  tags = var.tags
}