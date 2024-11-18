output "identity_provider" {
  value = "cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.users.id}"
}
