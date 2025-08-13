# Infrastructure

## Overview

This section provides an overview of the infrastructure components used in this project, along with why certain technologies were chosen, the patterns considered and alternatives evaluated.

## Implemented Components

### Overview

The infrastructure deployed by the tool includes the following:

- **API Gateway**: The entry point for all API requests, responsible for routing requests and applying authentication.
- **AWS Lambda**: The compute service that runs backend code in response to events. In this case, a single FastAPI application.
- **AWS WAF**: The web application firewall that helps restrict access to the API to only certain IP addresses (i.e. Developer MacBook IPs).
- **WAF IP Set**: A set of IP addresses that are allowed or denied access to the API.
- **Amazon Cognito**: Integrates API Gateway with existing Cognito User Pools from our other services (i.e. Digital Landscape and Tech Audit Tool).

See the diagram below for a visual representation of the infrastructure components and their interactions.

<!-- TODO: Make Diagram -->
![Infrastructure Diagram](./assets/infrastructure-diagram.png)

### API Gateway

This is configured so that as much traffic as possible is proxied to AWS Lambda. This is to avoid duplicating the backend logic in multiple places, such as which endpoints are available.

The configuration contains a single root endpoint for the API, allowing all traffic to be handled by the FastAPI application running in AWS Lambda.

The endpoints that should be defined within API Gateway are those which need restricted access via an authorizer.

See the diagram below for a visual representation of the API Gateway configuration.

<!-- TODO: Make Diagram -->
![API Gateway Diagram](./assets/api-gateway-diagram.png)

#### Authorizers: Cognito

As mentioned above, certain API Gateway endpoints require user authentication. This is achieved by integrating with Amazon Cognito. Most of our services use Cognito User Pools to manage user access. Using a Cognito Authorizer allows our API to build upon the existing user management infrastructure.

More information around how this increase security, and its organisation in the potential production API can be found in the [security section](./security.md).

### AWS Lambda

AWS Lambda is used to host our FastAPI container. This allows us to run our application code in response to events without having to manage the underlying infrastructure.

Having FastAPI run as a Lambda prevents the service from being constantly online, even if it is not being used. Lambda executions are also very cheap.

There is a main drawback with this, in that there is a cold start time associated with Lambda functions. If a lambda is particularly large, the cold start time can be significant, however, for our usage and expected traffic, this is an acceptable trade-off.

#### The Lambda-lith

This PoC uses a lambda-lith approach, where a single lambda deals with traffic for all API Gateway routes. This simplifies deployment and reduces the overhead of managing multiple lambda functions.

Alternatives such as using the FAT or single purpose lambdas may be a possibility in the future, however this raises the complexity of the deployment and the management overhead.

See [The Lambda Trilogy](https://github.com/cdk-patterns/serverless/tree/main/the-lambda-trilogy) for an overview of each pattern.

### Web Application Firewall (AWS WAF)

AWS WAF is used to restrict access to the API to only certain IP addresses. This is essential to secure our API so it is not exposed to the public internet. 

Using a WAF and allowed IP set ensures that it is accessible on the internet for local development purposes, but only for intended people.

More on this is discussed in the [security section](./security.md).

## Alternative Setup: Fargate + Load Balancer

An alternative setup to our API Gateway and Lambda approach would be to use AWS Fargate with an Application Load Balancer (ALB) to route traffic. This negates some of the downsides of our existing approach - including the cold start times associated with Lambda functions. In addition to this, we already have infrastructure in place for containerized applications, making this a more familiar setup for our team.

The reason why we have not pursued this option is because API Gateway seems to be a more encouraged pattern by AWS, and it makes a few aspects of our architecture simpler, such as controlling access to endpoints and managing API versions.

Below provides an example diagram of the Fargate + Load Balancer setup.

<!-- TODO: Make Diagram -->
![Fargate + Load Balancer Diagram](./assets/fargate-load-balancer-diagram.png)
