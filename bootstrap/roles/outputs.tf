output "platform_ci_role_arn" {
    value = aws_iam_role.platform_ci_role.arn
}

output "platform_cd_role_arn" {
    value = aws_iam_role.platform_cd_role.arn
}

output "service_ci_role_arn" {
    value = aws_iam_role.service_ci_role.arn
}

output "service_cd_role_arn" {
    value = aws_iam_role.service_cd_role.arn
}

output "database_ci_role_arn" {
    value = aws_iam_role.database_ci_role.arn
}

output "database_cd_role_arn" {
    value = aws_iam_role.database_cd_role.arn
}

output "ecs_execution_role_arn" {
  value = module.ecs_execution_roles.role_name_arns["ecs-task-execution-role"]
}

output "ecs_task_role_arns" {
  value = module.task_roles.role_name_arns
}

output "ecs_service_update_role_arn" {
  value = aws_iam_role.service_update_role.arn
}