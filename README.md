# FastAPI Proof of Concept
A PoC to investigate FastAPI and its deployment to AWS. This forms a "blueprint" for KEH's future database API.

## Contents

- [FastAPI Proof of Concept](#fastapi-proof-of-concept)
  - [Contents](#contents)
  - [Overview](#overview)
  - [Scope](#scope)
  - [Project Structure](#project-structure)
  - [Getting Started](#getting-started)
  - [Deployment to AWS](#deployment-to-aws)
    - [Push Docker Image to ECR](#push-docker-image-to-ecr)
    - [Terraform](#terraform)
      - [Cleanup](#cleanup)

## Overview

This repository contains a FastAPI application that serves as a proof of concept for building RESTful APIs and deploying them to AWS.

It includes examples of how to set up and organise a FastAPI project, how to use Pydantic for data validation, and how to deploy the application using Docker and AWS services. 

The application also provides a good way to investigate the use of AWS Cognito for user authentication when making API requests.

## Scope

The scope of this project is to provide a basic FastAPI blueprint which we can expand upon to build our future database API. This will help us understand the structure and best practices for building APIs with FastAPI, as well as how to deploy them effectively.

When it comes to building the actual database API, the following will need to be added on top of this PoC:

- Integration with the database (PostgreSQL using Psycopg)
- Implementation of the actual API endpoints for database operations
- Automated testing
- Further linting and code quality checks
- MkDocs for technical documentation
- Concourse integration for CI/CD

## Project Structure

The project is structured as follows:

```
fastapi-poc/
└── src/                         # Source code for the FastAPI application
    ├── main.py                  # Entry point for the FastAPI application
    └── api/                     # Contains API routes and logic
        └── v0/                  # Versioned API routes
            ├── api.py           # Main API router
            └── endpoints/       # Contains individual API endpoint definitions
                ├── projects.py      # Project-related API endpoints
                └── technologies.py  # Technology-related API endpoints
```

## Getting Started

To get started with this FastAPI PoC, follow these steps:

1. Create and activate a Python virtual environment.

  ```bash
  python3 -m venv venv
  source venv/bin/activate
  ```

2. Install the required dependencies.

  ```bash
  poetry install
  ```

3. Change to the `src` directory.

  ```bash
  cd src
  ```

4. Run the FastAPI application.

  ```bash
  uvicorn main:app --reload
  ```

5. Open your browser and navigate to `http://localhost:8000/docs` to view the API documentation and test the endpoints.

## Deployment to AWS

### Push Docker Image to ECR

To deploy the FastAPI application to AWS, we need to first build a Docker image and push it to Amazon Elastic Container Registry (ECR).

**Note:** These commands can be found within AWS ECR's console under the "View push commands" section.

1. Login to AWS ECR:
   
  ```bash
  aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com
  ```

  **Note:** This requires the AWS CLI to be installed and configured with your AWS credentials. You can export them using:

  ```bash
  export AWS_ACCESS_KEY_ID=<your-access-key-id>
  export AWS_SECRET_ACCESS_KEY=<your-secret-access-key>
  ```

2. Build the Docker image:

  ```bash
  docker build -t fastapi-poc .
  ```

3. Tag the Docker image:

  ```bash
  docker tag fastapi-poc:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<repository-name>:<tag>
  ```

4. Push the Docker image to ECR:

  ```bash
  docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<repository-name>:<tag>
  ```

### Terraform

Now that the Docker image is in ECR, we can use Terraform to resource the necessary AWS infrastructure to run the FastAPI application.

1. Change to the `terraform/service` directory:

  ```bash
  cd terraform/service
  ```

2. Initialize Terraform:

  ```bash
  terraform init -backend-config="env/<env>/backend-<env>.tfbackend" -reconfigure
  ``` 

3. Refresh the Terraform state:

  ```bash
  terraform refresh
  ```

4. Plan the Terraform deployment:

  ```bash
  terraform plan
  ```

5. Apply the Terraform deployment:

  ```bash
  terraform apply
  ```

6. Once the deployment is complete, you can access the FastAPI application using the URL provided in the output of the `terraform apply` command.

#### Cleanup

To clean up the resources created by Terraform, you can run:

```bash
terraform destroy
```

This will remove all the AWS resources created by the Terraform configuration.
