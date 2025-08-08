data "aws_ecr_repository" "fastapi_ecr" {
  name = "${var.env_name}-fastapi-poc"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.env_name}-tf-state"
    key    = "${var.env_name}-ecs-infra/terraform.tfstate"
    region = "eu-west-2"
  }
}