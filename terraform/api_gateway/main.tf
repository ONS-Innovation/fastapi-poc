

resource "aws_api_gateway_rest_api" "fastapi_gateway" {
    name        = "fastapi-gateway"
    description = "API Gateway for FastAPI application"

    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

resource "aws_api_gateway_authorizer" "fastapi_authorizer" {
    name          = "fastapi-authorizer"
    rest_api_id  = aws_api_gateway_rest_api.fastapi_gateway.id
    type          = "COGNITO_USER_POOLS"
    identity_source = "method.request.header.Authorization"
    provider_arns = [
        data.terraform_remote_state.tech_audit_tool_api_auth.outputs.tech_audit_tool_user_pool_arn,
        data.terraform_remote_state.digital_landscape_auth.outputs.cognito_reviewer_user_pool_arn
    ]
}

// Setup root resource
resource "aws_api_gateway_method" "proxy_root" {
    rest_api_id   = aws_api_gateway_rest_api.fastapi_gateway.id
    resource_id   = aws_api_gateway_rest_api.fastapi_gateway.root_resource_id
    http_method   = "ANY"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_root_integration" {
    rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
    resource_id = aws_api_gateway_rest_api.fastapi_gateway.root_resource_id
    http_method = aws_api_gateway_method.proxy_root.http_method

    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = var.aws_lambda_function_invoke_arn
}

// Setup proxy resource to handle all methods
// This will allow the FastAPI application to handle all requests
resource "aws_api_gateway_resource" "proxy" {
    rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
    parent_id   = aws_api_gateway_rest_api.fastapi_gateway.root_resource_id
    path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
    rest_api_id   = aws_api_gateway_rest_api.fastapi_gateway.id
    resource_id   = aws_api_gateway_resource.proxy.id
    http_method   = "ANY"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_integration" {
    rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
    resource_id = aws_api_gateway_resource.proxy.id
    http_method = aws_api_gateway_method.proxy_method.http_method

    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = var.aws_lambda_function_invoke_arn
}

// Now we can specify any additional endpoints that specifically need Cognito authorisation
// For example, we need /api/v0/projects to be protected by Cognito if POST is used
resource "aws_api_gateway_resource" "api" {
    rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
    parent_id   = aws_api_gateway_rest_api.fastapi_gateway.root_resource_id
    path_part   = "api"
}

resource "aws_api_gateway_resource" "v0" {
    rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
    parent_id   = aws_api_gateway_resource.api.id
    path_part   = "v0"
}

resource "aws_api_gateway_resource" "projects" {
    rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
    parent_id   = aws_api_gateway_resource.v0.id
    path_part   = "projects"
}

resource "aws_api_gateway_method" "projects_post" {
    rest_api_id   = aws_api_gateway_rest_api.fastapi_gateway.id
    resource_id   = aws_api_gateway_resource.projects.id
    http_method   = "POST"
    authorization = "COGNITO_USER_POOLS"
    authorizer_id = aws_api_gateway_authorizer.fastapi_authorizer.id
}

// Same for a delete method to /api/v0/projects/{project_id}
resource "aws_api_gateway_method" "projects_delete" {
    rest_api_id   = aws_api_gateway_rest_api.fastapi_gateway.id
    resource_id   = aws_api_gateway_resource.projects.id
    http_method   = "DELETE"
    authorization = "COGNITO_USER_POOLS"
    authorizer_id = aws_api_gateway_authorizer.fastapi_authorizer.id
}

// Lambda integration for the POST method on /api/v0/projects
resource "aws_api_gateway_integration" "projects_post_integration" {
    rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
    resource_id = aws_api_gateway_resource.projects.id
    http_method = aws_api_gateway_method.projects_post.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = var.aws_lambda_function_invoke_arn
}

// Lambda integration for the DELETE method on /api/v0/projects/{project_id}
resource "aws_api_gateway_integration" "projects_delete_integration" {
    rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
    resource_id = aws_api_gateway_resource.projects.id
    http_method = aws_api_gateway_method.projects_delete.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = var.aws_lambda_function_invoke_arn
}

// Give API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "api_gateway_invoke" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = var.aws_lambda_function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_api_gateway_rest_api.fastapi_gateway.execution_arn}/*/*"
}


// Create Deployment for the API Gateway
resource "aws_api_gateway_deployment" "fastapi_gateway_deployment" {
    rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id

    lifecycle {
        create_before_destroy = true
    }

    depends_on = [
        aws_api_gateway_integration.proxy_root_integration,
        aws_api_gateway_integration.proxy_integration,
        aws_api_gateway_integration.projects_post_integration,
        aws_api_gateway_integration.projects_delete_integration
    ]
}

resource "aws_api_gateway_stage" "fastapi_gateway_stage" {
    rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
    stage_name  = "dev"
    deployment_id = aws_api_gateway_deployment.fastapi_gateway_deployment.id

    access_log_settings {
        destination_arn = aws_cloudwatch_log_group.api_gateway.arn
        format = jsonencode({
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        caller         = "$context.identity.caller"
        user           = "$context.identity.user"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        resourcePath   = "$context.resourcePath"
        status         = "$context.status"
        protocol       = "$context.protocol"
        responseLength = "$context.responseLength"
        errorMessage   = "$context.error.message"
        errorType      = "$context.error.responseType"
        })
    }
}

resource "aws_api_gateway_method_settings" "fastapi_gateway_method_settings" {
    rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
    stage_name  = aws_api_gateway_stage.fastapi_gateway_stage.stage_name

    method_path = "*/*"

    settings {
        metrics_enabled = true
        logging_level   = "INFO"
        data_trace_enabled = false
    }
}

// TODO: Domain Name