resource "aws_lambda_function" "fastapi_lambda" {
  function_name = "fastapi-lambda"
  role          = aws_iam_role.fastapi_lambda_role.arn
  image_uri     = "${data.aws_ecr_repository.fastapi_ecr.repository_url}:${var.image_tag}"
  package_type  = "Image"
  architectures = ["x86_64"]
   timeout     = 30

   logging_config {
    log_format = "JSON"
   }
   vpc_config {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
   }
}

resource "aws_cloudwatch_log_group" "fastapi_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.fastapi_lambda.function_name}"
  retention_in_days = 14
}
