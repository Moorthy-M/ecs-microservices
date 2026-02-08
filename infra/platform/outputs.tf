output "alb_arn" {
  value = module.alb.alb_arn
}

output "alb_target_group_arn" {
  value = module.alb.alb_target_group_arn
}

output "alb_sg_id" {
  value = module.alb.alb_sg_id
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}