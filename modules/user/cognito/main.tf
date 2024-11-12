resource "aws_cognito_user_pool" "users" {
  name = "users"
  username_attributes = var.cognito_username_attributes
  auto_verified_attributes = var.cognito_verified_attributes

  account_recovery_setting {
    recovery_mechanism {
      name = "verified_email"
      priority = 1
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
}