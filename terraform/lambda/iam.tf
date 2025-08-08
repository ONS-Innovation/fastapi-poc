data "aws_iam_policy_document" "fastapi_lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "fastapi_lambda_role" {
  name               = "${var.env_name}-fastapi-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.fastapi_lambda_assume_role_policy.json 
}

data "aws_iam_policy_document" "vpc_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface",
      "ec2:CreateTags"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "vpc_permissions" {
  name        = "${var.env_name}-fastapi-vpc-permissions"
  description = "IAM policy for VPC permissions for FastAPI Lambda function"
  policy      = data.aws_iam_policy_document.vpc_permissions.json
}

resource "aws_iam_role_policy_attachment" "vpc_policy" {
  role       = aws_iam_role.fastapi_lambda_role.name
  policy_arn = aws_iam_policy.vpc_permissions.arn
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.fastapi_lambda_log_group.arn,
    ]
  }
}

resource "aws_iam_policy" "fastapi_lambda_logging_policy" {
  name        = "${var.env_name}-fastapi-lambda-logging-policy"
  description = "Policy for FastAPI Lambda logging"

  policy = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "fastapi_lambda_logging_attachment" {
  role       = aws_iam_role.fastapi_lambda_role.name
  policy_arn = aws_iam_policy.fastapi_lambda_logging_policy.arn
}
