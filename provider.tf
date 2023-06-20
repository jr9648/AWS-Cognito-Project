terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}

//provider "aws" {
//  region                      = "eu-west-1"
//  skip_credentials_validation = true
//  skip_metadata_api_check     = true
//
//  # Some services, like HTTP API Gateway, are only available in Pro-version - https://localstack.cloud/#pricing
//  endpoints {
//    apigateway     = "http://localhost:4566"
//    dynamodb       = "http://localhost:4566"
//    iam            = "http://localhost:4566"
//    lambda         = "http://localhost:4566"
//    s3             = "http://localhost:4566"
//  }
//}