variable "user_pool_name" {}
variable "admin_group_name" {}
variable "standard_group_name" {}

# Create Cognito User Pool
resource "aws_cognito_user_pool" "my_user_pool" {
  name = var.user_pool_name

  # Define user pool policies and other settings
  # ...

  # Define schema for user attributes
  # ...

  # Define user pool client
  client {
    name             = "my-user-pool-client"
    generate_secret  = true
    refresh_token_validity = 30
  }
}

# Create Cognito user groups
resource "aws_cognito_user_group" "admin_group" {
  name       = var.admin_group_name
  user_pool_id = aws_cognito_user_pool.my_user_pool.id
}

resource "aws_cognito_user_group" "standard_group" {
  name       = var.standard_group_name
  user_pool_id = aws_cognito_user_pool.my_user_pool.id
}