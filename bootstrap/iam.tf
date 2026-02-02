// Create Child Module

module "iam" {
  source              = "./roles"
  tf_state_bucket_arn = local.tf_state_bucket_arn
  oidc_arn            = var.oidc_arn
  ci_trust            = data.aws_iam_policy_document.ci_trust.json
  cd_trust            = data.aws_iam_policy_document.cd_trust.json
  tags                = var.tags
}