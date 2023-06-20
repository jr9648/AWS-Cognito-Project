# Define variables
variable "aws_region" {
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  default     = "my-user-pool"
}

variable "admin_group_name" {
  description = "Name of the Cognito admin user group"
  default     = "AdminUser"
}

variable "standard_group_name" {
  description = "Name of the Cognito standard user group"
  default     = "StandardUser"
}

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

# Create IAM policies and roles
resource "aws_iam_policy" "admin_policy" {
  name        = "admin_policy"
  description = "Policy to grant full access to API endpoints"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "FullAccess",
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "standard_policy" {
  name        = "standard_policy"
  description = "Policy to grant read-only access to API endpoints"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnlyAccess",
      "Effect": "Allow",
      "Action": "execute-api:Invoke",
      "Resource": "arn:aws:execute-api:${var.aws_region}:<API_GATEWAY_ID>:*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "admin_role" {
  name               = "admin_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.my_user_pool.id}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.my_user_pool.id}:aud": aws_cognito_user_pool.my_user_pool.client[0].client_id
        }
      }
    }
  ]
}
EOF

  # Attach the admin policy to the admin role
  policy {
    name   = "admin_policy"
    policy_arn = aws_iam_policy.admin_policy.arn
  }
}

resource "aws_iam_role" "standard_role" {
  name               = "standard_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.my_user_pool.id}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.my_user_pool.id}:aud": aws_cognito_user_pool.my_user_pool.client[0].client_id
        }
      }
    }
  ]
}
EOF

  # Attach the standard policy to the standard role
  policy {
    name   = "standard_policy"
    policy_arn = aws_iam_policy.standard_policy.arn
  }
}

# Configure API Gateway restrictions based on Cognito groups
data "aws_iam_policy_document" "api_gateway_policy_document" {
  statement {
    sid       = "AllowAdminAccess"
    effect    = "Allow"
    actions   = ["execute-api:Invoke"]
    resources = ["arn:aws:execute-api:${var.aws_region}:<API_GATEWAY_ID>:*"]
    condition {
      test     = "StringEquals"
      variable = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.my_user_pool.id}:sub"
      values   = [aws_cognito_user_group.admin_group.id]
    }
  }

  statement {
    sid       = "AllowStandardAccess"
    effect    = "Allow"
    actions   = ["execute-api:Invoke"]
    resources = ["arn:aws:execute-api:${var.aws_region}:<API_GATEWAY_ID>:GET/*"]
    condition {
      test     = "StringEquals"
      variable = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.my_user_pool.id}:sub"
      values   = [aws_cognito_user_group.standard_group.id]
    }
  }
}

resource "aws_iam_policy" "api_gateway_policy" {
  name   = "api_gateway_policy"
  policy = data.aws_iam_policy_document.api_gateway_policy_document.json
}

# Attach API Gateway policy to the Cognito roles
resource "aws_iam_role_policy_attachment" "admin_api_gateway_attachment" {
  role       = aws_iam_role.admin_role.name
  policy_arn = aws_iam_policy.api_gateway_policy.arn
}

resource "aws_iam_role_policy_attachment" "standard_api_gateway_attachment" {
  role       = aws_iam_role.standard_role.name
  policy_arn = aws_iam_policy.api_gateway_policy.arn
}
