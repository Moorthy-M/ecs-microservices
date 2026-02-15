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

module "services" {
  for_each = var.services

  source = "../../../modules/ecs"
  //source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//ecs?ref=v1.release"

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