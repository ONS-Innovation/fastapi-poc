// Get Cognito User Pool ARNs for services
data "terraform_remote_state" "tech_audit_tool_api_auth" {
    backend = "s3"
    config = {
        bucket = "sdp-dev-tf-state"
        key    = "sdp-dev-tech-audit-tool-api-auth/terraform.tfstate"
        region = "eu-west-2"
    }
}

data "terraform_remote_state" "digital_landscape_auth" {
    backend = "s3"
    config = {
        bucket = "sdp-dev-tf-state"
        key    = "sdp-dev-ecs-digital-landscape-auth/terraform.tfstate"
        region = "eu-west-2"
    }
}