resource "aws_iam_role" "cognito_admin_role" {
  name = "cognito-admin-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_user_pool.example.id
          },
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "api_gateway_policy" {
  name        = "api-gateway-policy"
  description = "IAM policy for API Gateway access"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "execute-api:Invoke",
        Effect   = "Allow",
        Resource = "${var.api-arn}/*/*/*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_attachment" {
  policy_arn = aws_iam_policy.api_gateway_policy.arn
  role       = aws_iam_role.cognito_admin_role.name
}

resource "aws_iam_role" "cognito_standard_role" {
  name = "cognito-standard-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_user_pool.example.id
          },
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "api_gateway_standard_policy" {
  name        = "api-gateway-standard-policy"
  description = "IAM policy for API Gateway read-only access"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "execute-api:Invoke",
        Effect   = "Allow",
        Resource = "${var.api-arn}/*/GET/*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_standard_attachment" {
  policy_arn = aws_iam_policy.api_gateway_standard_policy.arn
  role       = aws_iam_role.cognito_standard_role.name
}
