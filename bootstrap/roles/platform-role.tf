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
    sid    = "SecurityGroupAccess"
    effect = "Allow"
    actions = [
      "ec2:CreateSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DeleteSecurityGroup",
      "ec2:CreateTags",

      "ec2:DescribeAccountAttributes",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeRouteTables"
    ]

    resources = ["*"]
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
  
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:ModifyRule",
  
      "elasticloadbalancing:Describe*"
    ]

    resources = ["*"]
  }

  //This needs only when first time ALB creation
  statement {
    sid    = "ServiceLinkedRoleCreateAccess"
    effect = "Allow"
    actions = ["iam:CreateServiceLinkedRole"]

    resources = ["*"]

    condition {
      test = "StringEquals"
      variable = "iam:AWSServiceName"
      values = ["elasticloadbalancing.amazonaws.com"]
    }
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
    "ecs:ListClusters",
    "ecs:TagResource"
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

  tags = merge(var.tags,{
    Name        = "role-ci-ecs-microservices"
  })
}

// Create Permission Policy for CI
resource "aws_iam_policy" "platform_ci_policy" {
  name   = "terraform-ci-ecs-microservices-permission-policy"
  policy = data.aws_iam_policy_document.platform_ci_permission.json

  tags =  merge(var.tags,{
    Name        = "policy-ci-ecs-microservices"
  })
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

  tags = merge(var.tags,{
    Name        = "role-cd-ecs-microservices"
  })
}

// Create Permission Policy to Create ALB, ECS Cluster
resource "aws_iam_policy" "platform_cd_policy" {
  name   = "terraform-cd-ecs-microservices-permission-policy"
  policy = data.aws_iam_policy_document.platform_cd_permission.json

  /* lifecycle {
    prevent_destroy = true
  } */

  tags = merge(var.tags,{
    Name        = "policy-cd-ecs-microservices"
  })
}

// Attach Permission Policy to Role
resource "aws_iam_role_policy_attachment" "platform_cd_role_attach" {
  role       = aws_iam_role.platform_cd_role.name
  policy_arn = aws_iam_policy.platform_cd_policy.arn

  /* lifecycle {
    prevent_destroy = true
  } */
}