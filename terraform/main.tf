module "lambda" {
    source = "./lambda/"

    # Variables
    env_name = var.env_name
    image_tag = var.image_tag
}

module "api_gateway" {
    source = "./api_gateway/"

    # Variables
    aws_lambda_function_invoke_arn = module.lambda.fastapi_lambda_function_invoke_arn
    aws_lambda_function_name       = module.lambda.fastapi_lambda_function_name
}