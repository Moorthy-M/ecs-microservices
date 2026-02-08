data "aws_caller_identity" "account" {}

// Infra CI Permisssions
data "aws_iam_policy_document" "service_ci_permission" {
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
    sid    = "TerraformInfraPlatformStateRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [var.tf_state_bucket_arn, "${var.tf_state_bucket_arn}/ecs-microservices/platform/*"]
  }

  statement {
    sid    = "NetworkReadAccess"
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeRouteTables"
    ]

    resources = ["*"]
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

  statement {
    sid    = "IAMPassRole"
    effect = "Allow"
    actions = [ "iam:PassRole" ]

    resources = [
    "arn:aws:iam::${data.aws_caller_identity.account.account_id}:role/ecs-task-execution-role",
    "arn:aws:iam::${data.aws_caller_identity.account.account_id}:role/ecs-task-role-*"
    ]
  }
}

// Infra CD Permissions
data "aws_iam_policy_document" "service_cd_permission" {
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
    sid    = "TerraformInfraPlatformStateRead"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [var.tf_state_bucket_arn, "${var.tf_state_bucket_arn}/ecs-microservices/platform/*"]
  }

  statement {
    sid    = "NetworkReadAccess"
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeRouteTables",
      "ec2:DescribeNetworkInterfaces"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CreateALBTargetListener"
    effect = "Allow"
    actions = [
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
  
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:ModifyRule",
  
      "elasticloadbalancing:Describe*"
    ]

    resources = ["*"]
  }

  statement {
    sid   = "ReadECSCluster"
    effect = "Allow"
    actions = [
       "ecs:DescribeClusters",
       "ecs:ListClusters",
       "ecs:AddTags"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CreateECSServiceTask"
    effect = "Allow"
    actions = [
      "ecs:CreateService",
      "ecs:UpdateService",
      "ecs:DeleteService",
      "ecs:DescribeServices",

      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:ListTaskDefinitions",

      "ecs:CreateService"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "IAMPassRole"
    effect = "Allow"
    actions = [ "iam:PassRole" ]

    resources = [
    "arn:aws:iam::${data.aws_caller_identity.account.account_id}:role/ecs-task-execution-role",
    "arn:aws:iam::${data.aws_caller_identity.account.account_id}:role/ecs-task-role-*"
    ]
  }
}

// Create Role for CI
resource "aws_iam_role" "service_ci_role" {
  name               = "terraform-ci-infra-service-role"
  assume_role_policy = var.ci_trust

 /*  lifecycle {
    prevent_destroy = true
  } */

  tags =  merge(var.tags,{
    Name        = "role-ci-infra-service"
  })
}

// Create Permission Policy for CI
resource "aws_iam_policy" "service_ci_policy" {
  name   = "terraform-ci-infra-service-permission-policy"
  policy = data.aws_iam_policy_document.platform_ci_permission.json

  tags =  merge(var.tags,{
    Name        = "policy-ci-infra-service"
  })
}

//Attach Permission Policy to Role
resource "aws_iam_role_policy_attachment" "service_ci_role_attach" {
  role       = aws_iam_role.platform_ci_role.name
  policy_arn = aws_iam_policy.platform_ci_policy.arn

  /* lifecycle {
    prevent_destroy = true
  } */
}

// Create Role for CD
resource "aws_iam_role" "service_cd_role" {
  name               = "terraform-cd-infra-service-role"
  assume_role_policy = var.cd_trust

  /* lifecycle {
    prevent_destroy = true
  } */

  tags =  merge(var.tags,{
    Name        = "role-cd-infra-service"
  })
}

// Create Permission Policy to Create ALB, ECS Cluster
resource "aws_iam_policy" "service_cd_policy" {
  name   = "terraform-cd-infra-service-permission-policy"
  policy = data.aws_iam_policy_document.platform_cd_permission.json

  /* lifecycle {
    prevent_destroy = true
  } */

  tags =  merge(var.tags,{
    Name        = "policy-cd-infra-service"
  })
}

// Attach Permission Policy to Role
resource "aws_iam_role_policy_attachment" "service_cd_role_attach" {
  role       = aws_iam_role.platform_cd_role.name
  policy_arn = aws_iam_policy.platform_cd_policy.arn

  /* lifecycle {
    prevent_destroy = true
  } */
}

// Service Execution Role
module "ecs_execution_roles" {
  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//iam/role?ref=iam-v2"
  create_role = {
    "ecs-task-execution-role" = {
    trust = {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    managed_policy = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  }
  }

  tags  = var.tags
}

// Create Policy
module "task_policies" {
  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//iam/policy?ref=iam-v1"
  create_policy = {
    "service1-permission-policy" = {
      sid = "AccessForService1"
      actions = [
        "s3:GetObject",
        "s3:ListBucket"
      ]

      resources = [var.tf_state_bucket_arn, "${var.tf_state_bucket_arn}/ecs-microservices/*"]
    }
  }

  tags  = var.tags
}

/** Role name should be like this => {service_name}-role **/

// Task Role
module "task_roles" {
  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//iam/role?ref=iam-v2"
  create_role = {
    "service1-role" = {
      trust = {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
      }

      permission_policy = [module.task_policies.policies["service1-permission-policy"]]
    }
  }

  depends_on = [ module.task_policies ]
  tags  = var.tags
}