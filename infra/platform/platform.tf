// Import Network Stack
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-moorthy-terraform-state"
    key    = "Network/terraform.tfstate"
    region = "ap-south-1"
  }
}

// Create Application Load Balancer
module "alb" {
  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//alb?ref=alb-v1.release"

  alb_name = var.alb_name
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id
  subnets  = data.terraform_remote_state.network.outputs.public_subnets

  ingress_rules = var.alb_sg_ingress_rules
  egress_rules  = var.alb_sg_egress_rules

  alb_internal               = var.alb_internal
  enable_deletion_protection = var.enable_deletion_protection

  target_port     = var.alb_target_port
  target_protocol = var.alb_target_protocol
  target_type     = var.alb_target_type

  health_check_path     = var.health_check_path
  health_check_protocol = var.health_check_protocol
  health_check_matcher  = var.health_check_matcher
  health_check_interval = var.health_check_interval
  health_check_timeout  = var.health_check_timeout

  tags = merge(var.tags,
    {
      Name = "alb-internet-facing"
  })
}