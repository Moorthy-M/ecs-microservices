// Infra CI Permisssions
data "aws_iam_policy_document" "database_ci_permission" {
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
    sid    = "DatabaseReadAccess"
    effect = "Allow"
    actions = [
      "rds:ListTagsForResource",
      "rds:Describe*"
    ]

    resources = ["*"]
  }

statement {
    sid   = "ReadSecrets"
    effect = "Allow"
    actions = [
    "secretsmanager:DescribeSecret",
    "secretsmanager:ListSecrets",
    "secretsmanager:ListTagsForResource"
  ]

  resources = ["*"]
}

  statement {
    sid   = "KMSAccess"
    effect = "Allow"
    actions = [
    "kms:DescribeKey"
  ]

  resources = ["*"]
}
}

// Infra CD Permissions
data "aws_iam_policy_document" "database_cd_permission" {
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
      "ec2:DeleteTags",

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
    sid    = "CreateDatabase"
    effect = "Allow"
    actions = [
      "rds:CreateDBInstance",
      "rds:DeleteDBInstance",
      "rds:ModifyDBInstance",

      "rds:CreateDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",
      "rds:ModifyDBSubnetGroup",

      "rds:AddTagsToResource",
      "rds:RemoveTagsFromResource",

      "rds:ListTagsForResource",
      "rds:Describe*"
    ]

    resources = ["*"]
  }

  statement {
    sid   = "CreateSecrets"
    effect = "Allow"
    actions = [
    "secretsmanager:CreateSecret",
    "secretsmanager:DeleteSecret",
    "secretsmanager:DescribeSecret",
    "secretsmanager:GetSecretValue",
    "secretsmanager:PutSecretValue",
    "secretsmanager:UpdateSecret",
    "secretsmanager:TagResource",
    "secretsmanager:UntagResource",
    "secretsmanager:ListSecrets",
    "secretsmanager:ListTagsForResource"
  ]

  resources = ["*"]
  }

  statement {
    sid   = "KMSAccess"
    effect = "Allow"
    actions = [
    "kms:Encrypt",
    "kms:Decrypt",
    "kms:GenerateDataKey",
    "kms:DescribeKey"
  ]

  resources = ["*"]
}

// First Time Only needs
statement {
    sid    = "AllowDBServiceLinkedRole"
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    resources = ["*"]

    condition {
      test = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "rds.amazonaws.com",
        "secretsmanager.amazonaws.com"
      ]
    }
  }

}

// Create Role for CI
resource "aws_iam_role" "database_ci_role" {
  name               = "terraform-ci-infra-database-role"
  assume_role_policy = var.ci_trust

 /*  lifecycle {
    prevent_destroy = true
  } */

  tags = merge(var.tags,{
    Name        = "role-ci-infra-database"
  })
}

// Create Permission Policy for CI
resource "aws_iam_policy" "database_ci_policy" {
  name   = "terraform-ci-infra-database-permission-policy"
  policy = data.aws_iam_policy_document.database_ci_permission.json

  tags =  merge(var.tags,{
    Name        = "policy-ci-infra-database"
  })
}

//Attach Permission Policy to Role
resource "aws_iam_role_policy_attachment" "database_ci_role_attach" {
  role       = aws_iam_role.database_ci_role.name
  policy_arn = aws_iam_policy.database_ci_policy.arn

  /* lifecycle {
    prevent_destroy = true
  } */
}

// Create Role for CD
resource "aws_iam_role" "database_cd_role" {
  name               = "terraform-cd-infra-database-role"
  assume_role_policy = var.cd_trust

  /* lifecycle {
    prevent_destroy = true
  } */

  tags = merge(var.tags,{
    Name        = "role-cd-infra-database"
  })
}

// Create Permission Policy to Create Database
resource "aws_iam_policy" "database_cd_policy" {
  name   = "terraform-cd-infra-database-permission-policy"
  policy = data.aws_iam_policy_document.database_cd_permission.json

  /* lifecycle {
    prevent_destroy = true
  } */

  tags = merge(var.tags,{
    Name        = "policy-cd-infra-database"
  })
}

// Attach Permission Policy to Role
resource "aws_iam_role_policy_attachment" "database_cd_role_attach" {
  role       = aws_iam_role.database_cd_role.name
  policy_arn = aws_iam_policy.database_cd_policy.arn

  /* lifecycle {
    prevent_destroy = true
  } */
}
