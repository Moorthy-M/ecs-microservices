locals {
  tf_state_bucket_arn = "arn:aws:s3:::s3-moorthy-terraform-state"
}

// Infra CI Trust Policy
data "aws_iam_policy_document" "ci_trust" {
  statement {
    sid    = "TrustPolicyForAssumeRole"
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:Moorthy-M/ecs-microservices:pull_request",
        "repo:Moorthy-M/ecs-microservices:ref:refs/heads/*"
      ]
    }
  }
}

// Infra Layer CD Trust Policy
data "aws_iam_policy_document" "cd_trust" {
  statement {
    sid    = "TrustPolicyForAssumeRole"
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:Moorthy-M/ecs-microservices:ref:refs/heads/main"]
    }
  }
}