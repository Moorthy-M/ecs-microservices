locals {
  tf_state_bucket_platform_arn = "arn:aws:s3:::s3-moorthy-terraform-state"
}

// Infra CI Permisssions
data "aws_iam_policy_document" "platform_ci_permission" {
  statement {
    sid    = "TerraformStateRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [var.tf_state_bucket_arn, "${var.tf_state_bucket_arn}/ecs-microservices/*"]
  }

  statement {
    sid    = "TerraformNetworkStateRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [var.tf_state_bucket_arn, "${var.tf_state_bucket_arn}/Network/*"]
  }

  statement {
    sid    = "ALBReadAccess"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:Describe*"
    ]

    resources = ["*"]
  }
  statement {
    sid    = "ECSClusterReadAccess"
    effect = "Allow"
    actions = [
      "ecs:ListClusters",
      "ecs:DescribeClusters"
    ]

    resources = ["*"]
  }
  statement {
    sid    = "RestrictCreateUpdateDeleteAccess"
    effect = "Deny"
    actions = [
      "elasticloadbalancing:Create*",
      "elasticloadbalancing:Modify*",
      "elasticloadbalancing:Delete*",
      "ecs:Create*",
      "ecs:Update*",
      "ecs:RegisterTaskDefinition",
      "ecs:Delete*"
    ]

    resources = ["*"]
  }
}

// Infra CD Permissions
data "aws_iam_policy_document" "platform_cd_permission" {
  statement {
    sid    = "TerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [var.tf_state_bucket_arn, "${var.tf_state_bucket_arn}/ecs-microservices/*"]
  }

  statement {
    sid    = "TerraformNetworkStateRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [var.tf_state_bucket_arn, "${var.tf_state_bucket_arn}/Network/*"]
  }

  statement {
    sid    = "CreateALB"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
    "elasticloadbalancing:DeleteLoadBalancer",
    "elasticloadbalancing:ModifyLoadBalancerAttributes",
    "elasticloadbalancing:SetSecurityGroups",
    "elasticloadbalancing:SetSubnets",

    "elasticloadbalancing:CreateTargetGroup",
    "elasticloadbalancing:DeleteTargetGroup",
    "elasticloadbalancing:ModifyTargetGroup",
    "elasticloadbalancing:ModifyTargetGroupAttributes",

    "elasticloadbalancing:CreateListener",
    "elasticloadbalancing:DeleteListener",
    "elasticloadbalancing:ModifyListener",

    "elasticloadbalancing:CreateRule",
    "elasticloadbalancing:DeleteRule",
    "elasticloadbalancing:ModifyRule",

    "elasticloadbalancing:Describe*"
    ]

    resources = ["*"]
  }

  statement {
    sid   = "CreateECSCluster"
    effect = "Allow"
    actions = [
    "ecs:CreateCluster",
    "ecs:DeleteCluster",
    "ecs:DescribeClusters",
    "ecs:PutClusterCapacityProviders",
    "ecs:UpdateClusterSettings",
    "ecs:ListClusters"
  ]

  resources = ["*"]
}
}

// Create Role for CI
resource "aws_iam_role" "platform_ci_role" {
  name               = "terraform-ci-ecs-microservices-role"
  assume_role_policy = var.ci_trust

 /*  lifecycle {
    prevent_destroy = true
  } */

  tags = {
    Name        = "role-ci-ecs-microservices"
    Project     = "ecs-microservices"
    Environment = "production"
  }
}

// Create Permission Policy for CI
resource "aws_iam_policy" "platform_ci_policy" {
  name   = "terraform-ci-ecs-microservices-permission-policy"
  policy = data.aws_iam_policy_document.platform_ci_permission.json

  tags = {
    Name        = "policy-ci-ecs-microservices"
    Project     = "ecs-microservices"
    Environment = "production"
  }
}

//Attach Permission Policy to Role
resource "aws_iam_role_policy_attachment" "platform_ci_role_attach" {
  role       = aws_iam_role.platform_ci_role.name
  policy_arn = aws_iam_policy.platform_ci_policy.arn

  /* lifecycle {
    prevent_destroy = true
  } */
}

// Create Role for CD
resource "aws_iam_role" "platform_cd_role" {
  name               = "terraform-cd-ecs-microservices-role"
  assume_role_policy = var.cd_trust

  /* lifecycle {
    prevent_destroy = true
  } */

  tags = {
    Name        = "role-cd-ecs-microservices"
    Project     = "ecs-microservices"
    Environment = "production"
  }
}

// Create Permission Policy to Create ALB, ECS Cluster
resource "aws_iam_policy" "platform_cd_policy" {
  name   = "terraform-cd-ecs-microservices-permission-policy"
  policy = data.aws_iam_policy_document.platform_cd_permission.json

  /* lifecycle {
    prevent_destroy = true
  } */

  tags = {
    Name        = "policy-cd-ecs-microservices"
    Project     = "ecs-microservices"
    Environment = "production"
  }
}

// Attach Permission Policy to Role
resource "aws_iam_role_policy_attachment" "platform_cd_role_attach" {
  role       = aws_iam_role.platform_cd_role.name
  policy_arn = aws_iam_policy.platform_cd_policy.arn

  /* lifecycle {
    prevent_destroy = true
  } */
}