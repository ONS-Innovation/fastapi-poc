# FastAPI Proof of Concept
A PoC to investigate FastAPI and its deployment to AWS. This forms a "blueprint" for KEH's future database API.

## Contents

- [FastAPI Proof of Concept](#fastapi-proof-of-concept)
  - [Contents](#contents)
  - [Overview](#overview)
  - [Scope](#scope)
  - [Project Structure](#project-structure)

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
