output "fastapi_lambda_function_name" {
  value = aws_lambda_function.fastapi_lambda.function_name
}

output "fastapi_lambda_function_arn" {
  value = aws_lambda_function.fastapi_lambda.arn
}

output "fastapi_lambda_log_group_name" {
  value = aws_cloudwatch_log_group.fastapi_lambda_log_group.name
}

output "fastapi_lambda_role_name" {
  value = aws_iam_role.fastapi_lambda_role.name
}