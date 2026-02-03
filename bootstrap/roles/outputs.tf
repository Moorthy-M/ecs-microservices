output "platform_ci_role_arn" {
    value = aws_iam_role.platform_ci_role.arn
}

output "platform_cd_role_arn" {
    value = aws_iam_role.platform_cd_role.arn
}