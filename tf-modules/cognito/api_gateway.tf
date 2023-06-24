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