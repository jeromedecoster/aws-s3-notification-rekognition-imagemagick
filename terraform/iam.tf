#
# lambda assume role policy
#

data aws_iam_policy_document assume_role_policy {
  statement {
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "lambda.amazonaws.com" ]
    }
  }
}

resource aws_iam_role lambda_role {
  name               = "${var.project_name}-lambda-role-${random_id.random.hex}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

output lambda_role {
  value = aws_iam_role.lambda_role.name
}

#
# lambda policy
#

data aws_iam_policy_document lambda_policy {
  statement {
    actions = [ 
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "rekognition:DetectLabels"
    ]
    resources = [ "*" ]
  }
}

resource aws_iam_policy lambda_policy {
  name   = "${var.project_name}-lambda-policy-${random_id.random.hex}"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource aws_iam_role_policy_attachment lambda_role_attached_policy {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

output lambda_policy {
  value = aws_iam_policy.lambda_policy.name
}