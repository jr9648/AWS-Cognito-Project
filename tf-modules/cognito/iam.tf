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