data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "secrets_manager_policy" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "db_conn_policy" {
  description = "Webapp database config retrieving"
  policy      = data.aws_iam_policy_document.secrets_manager_policy.json
}

resource "aws_iam_role" "db_conn_role" {
  name               = var.resource_names.role
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = { Name = var.resource_names.role }
}

resource "aws_iam_policy_attachment" "db_conn_policy_role_assoc" {
  name       = "db_conn"
  roles      = [aws_iam_role.db_conn_role.id]
  policy_arn = aws_iam_policy.db_conn_policy.arn
}