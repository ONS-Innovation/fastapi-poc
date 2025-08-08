module "lambda" {
    source = "./lambda/"

    # Variables
    env_name = var.env_name
    image_tag = var.image_tag
}

module "api_gateway" {
    source = "./api_gateway/"

    # Variables
    ## TBC
}