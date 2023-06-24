variable "api_name" {
  description = "Name of the API"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "ID of the Cognito user pool"
  type        = string
}

variable "admin_group_name" {
  description = "Name of the Cognito admin user group"
  type        = string
}

variable "standard_group_name" {
  description = "Name of the Cognito standard user group"
  type        = string
}

resource "aws_cognito_user_pool_client" "api_gateway_client" {
  name                   = "api-gateway-client"
  user_pool_id           = var.cognito_user_pool_id
  allowed_oauth_scopes   = ["openid"]
  callback_urls          = ["https://example.com/callback"]
  supported_identity_providers = ["COGNITO"]
}

resource "aws_apigatewayv2_api" "api_gateway" {
  name          = var.api_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  name          = "cognito-authorizer"
  api_id        = aws_apigatewayv2_api.api_gateway.id
  authorizer_type = "JWT"
  identity_source = "$request.header.Authorization"
  jwt_configuration {
    issuer        = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${var.cognito_user_pool_id}"
    audience     = [aws_cognito_user_pool_client.api_gateway_client.client_id]
  }
}

resource "aws_apigatewayv2_route" "admin_route" {
  api_id          = aws_apigatewayv2_api.api_gateway.id
  route_key       = "ANY /{proxy+}"
  target          = "integrations/${aws_apigatewayv2_integration.admin_integration.id}"
  authorization_type = "JWT"
  authorizer_id     = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

resource "aws_apigatewayv2_route" "standard_route" {
  api_id          = aws_apigatewayv2_api.api_gateway.id
  route_key       = "GET /{proxy+}"
  target          = "integrations/${aws_apigatewayv2_integration.standard_integration.id}"
  authorization_type = "JWT"
  authorizer_id     = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

resource "aws_apigatewayv2_integration" "admin_integration" {
  api_id         = aws_apigatewayv2_api.api_gateway.id
  integration_type = "HTTP_PROXY"
  integration_uri  = "http://backend-service.example.com/{proxy}"
}

resource "aws_apigatewayv2_integration" "standard_integration" {
  api_id         = aws_apigatewayv2_api.api_gateway.id
  integration_type = "HTTP_PROXY"
  integration_uri  = "http://backend-service.example.com/{proxy}"
}

resource "aws_apigatewayv2_deployment" "api_gateway_deployment" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  description = "Deployment for ${var.api_name}"
}

data "aws_region" "current" {}

output "api_url" {
  value = aws_apigatewayv2_api.api_gateway.api_endpoint
}