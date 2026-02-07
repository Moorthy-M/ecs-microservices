output "platform_ci_role_arn" {
  value = module.iam.platform_ci_role_arn
}

output "platform_cd_role_arn" {
  value = module.iam.platform_cd_role_arn
}

output "service_ci_role_arn" {
  value = module.iam.service_ci_role_arn
}

output "service_cd_role_arn" {
  value = module.iam.service_cd_role_arn
}

output "ecs_execution_role_arn" {
  value = module.iam.ecs_execution_role_arn
}

output "ecs_task_role_arns" {
  value = module.iam.ecs_task_role_arns
}