resource "aws_wafv2_ip_set" "api_gateway_ip_set" {
    name = "fastapi-gateway-ip-set"
    description = "IP set for FastAPI Gateway. Gives developers access to the API Gateway."
    scope = "REGIONAL"
    ip_address_version = "IPV4"
    addresses = [] // Empty for now. To be populated manually by developers.
}

resource "aws_wafv2_web_acl" "api_gateway_acl" {
    name        = "fastapi-gateway-web-acl"
    description = "Web ACL for FastAPI Gateway to restrict access to the API Gateway."
    scope       = "REGIONAL"

    default_action {
        block {}
    }

    rule {
        name     = "Allow-Listed-IPs"
        priority = 1

        action {
            allow {}
        }

        statement {
            ip_set_reference_statement {
                arn = aws_wafv2_ip_set.api_gateway_ip_set.arn
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name                = "AllowListedIPs"
            sampled_requests_enabled   = true
        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "FastAPIGatewayACL"
        sampled_requests_enabled   = true
    }
}

resource "aws_wafv2_web_acl_association" "api_gateway_association" {
    resource_arn = aws_api_gateway_stage.fastapi_gateway_stage.arn
    web_acl_arn  = aws_wafv2_web_acl.api_gateway_acl.arn
}
