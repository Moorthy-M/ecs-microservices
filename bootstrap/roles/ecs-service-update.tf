// Services CICD Permissions
data "aws_iam_policy_document" "service_cicd_permission" {

  statement {
    sid   = "ReadECSCluster"
    effect = "Allow"
    actions = [
       "ecs:DescribeClusters",
       "ecs:ListClusters"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AccessECSServiceTask"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:ListServices",
      "ecs:DescribeServices",

      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:ListTaskDefinitions",

      "ecs:ListTagsForResource"
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

// Create Role for CD
resource "aws_iam_role" "service_update_role" {
  name               = "terraform-service-update-role"
  assume_role_policy = var.cd_trust

  /* lifecycle {
    prevent_destroy = true
  } */

  tags =  merge(var.tags,{
    Name        = "role-cicd-service-update"
  })
}

// Create Permission Policy to Create ALB, ECS Cluster
resource "aws_iam_policy" "service_update_policy" {
  name   = "terraform-service-update-permission-policy"
  policy = data.aws_iam_policy_document.service_cicd_permission.json

  /* lifecycle {
    prevent_destroy = true
  } */

  tags =  merge(var.tags,{
    Name        = "policy-cicd-service-update"
  })
}

// Attach Permission Policy to Role
resource "aws_iam_role_policy_attachment" "service_update_role_attach" {
  role       = aws_iam_role.service_update_role.name
  policy_arn = aws_iam_policy.service_update_policy.arn

  /* lifecycle {
    prevent_destroy = true
  } */
}