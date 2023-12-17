
output "user_pool_id" {
  value = aws_cognito_user_pool.example.id
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.example.id
}

output "admin_group_id" {
  value = aws_cognito_user_group.admin.id
}

output "standard_group_id" {
  value = aws_cognito_user_group.standard.id
}

output "admin_role_arn" {
  value = aws_iam_role.cognito_admin_role.arn
}

output "standard_role_arn" {
  value = aws_iam_role.cognito_standard_role.arn
}

output "identity_pool_id" {
  value = aws_cognito_identity_pool.example.id
}