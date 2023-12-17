resource "aws_cognito_user_pool" "example" {
  name = "example-user-pool"

  schema {
    attribute_data_type = "String"
    name               = "email"
    required           = true
  }

  schema {
    attribute_data_type = "String"
    name               = "custom:role"
    required           = false
  }

  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  username_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

resource "aws_cognito_user_pool_client" "example" {
  name                   = "example-app-client"
  user_pool_id           = aws_cognito_user_pool.example.id
  generate_secret        = false
  allowed_oauth_flows    = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes   = ["openid"]
}

resource "aws_cognito_user_group" "admin" {
  name        = "admin"
  description = "Admin user group"
  precedence  = 1
  user_pool_id = aws_cognito_user_pool.example.id
}

resource "aws_cognito_user_group" "standard" {
  name        = "standard"
  description = "Standard user group"
  precedence  = 2
  user_pool_id = aws_cognito_user_pool.example.id
}

resource "aws_cognito_user_pool_domain" "example" {
  domain       = "example-domain"
  user_pool_id = aws_cognito_user_pool.example.id
}