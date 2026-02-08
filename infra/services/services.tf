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

resource "aws_security_group" "service" {
  name   = "service-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.platform.outputs.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags,
    {
      Name = "SG-service-sg"
  })
}

module "service1" {
  for_each = var.services

  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//ecs?ref=ecs-v3"

  cluster_id = data.terraform_remote_state.platform.outputs.ecs_cluster_id

  task_definition_family = each.value.family
  task_definition_cpu    = each.value.cpu
  task_definition_memory = each.value.memory

  execution_role_arn = data.terraform_remote_state.bootstrap.outputs.ecs_execution_role_arn
  task_role_arn      = data.terraform_remote_state.bootstrap.outputs.ecs_task_role_arns[each.value.task_role]

  container = each.value.container

  service_name          = each.key
  service_desired_count = each.value.desired_count
  service_launch_type   = each.value.launch_type

  service_target_group_arn = data.terraform_remote_state.platform.outputs.alb_target_group_arn

  service_subnets         = data.terraform_remote_state.network.outputs.private_app_subnets
  service_security_groups = [aws_security_group.service.id]

  depends_on = [aws_security_group.service]
  tags       = var.tags
}