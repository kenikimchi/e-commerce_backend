data "aws_region" "current" {}

resource "aws_cognito_user_pool" "users" {
  name                     = "users"
  username_attributes      = var.cognito_username_attributes
  auto_verified_attributes = var.cognito_verified_attributes

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
}

resource "aws_cognito_identity_pool" "authenticated_pool" {
  identity_pool_name               = "authenticated_pool"
  allow_unauthenticated_identities = true

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.site_client.id
    provider_name = "cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.users.id}"
  }
}

resource "aws_cognito_user_pool_client" "site_client" {
  name                                 = var.cognito_client_name
  user_pool_id                         = aws_cognito_user_pool.users.id
  callback_urls                        = var.cognito_client_callback_urls
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_scopes                 = ["openid", "email"]
}

# Guest Role
data "aws_iam_policy_document" "guest_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.authenticated_pool.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

resource "aws_iam_role" "guest_role" {
  name               = "guest_role"
  assume_role_policy = data.aws_iam_policy_document.guest_assume_role.json
}

data "aws_iam_policy_document" "guest_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["execute-api:Invoke"]
    resources = ["*"] # Remove placeholder once lambda functions are created
  }
}

resource "aws_iam_role_policy" "guest_role_policy" {
  name   = "guest_role_policy"
  role   = aws_iam_role.guest_role.id
  policy = data.aws_iam_policy_document.guest_policy_document.json
}

# Authenticated role
data "aws_iam_policy_document" "authenticated_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.authenticated_pool.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

resource "aws_iam_role" "authenticated_role" {
  name               = "authenticated_role"
  assume_role_policy = data.aws_iam_policy_document.authenticated_assume_role.json
}

data "aws_iam_policy_document" "authenticated_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["execute-api:Invoke"]
    resources = ["*"] # Remove placeholder once lambda functions are created
  }
}

resource "aws_iam_role_policy" "authenticated_role_policy" {
  name   = "authenticated_role_policy"
  role   = aws_iam_role.authenticated_role.id
  policy = data.aws_iam_policy_document.authenticated_policy_document.json
}

# Role attachment
resource "aws_cognito_identity_pool_roles_attachment" "cognito_role_attachments" {
  identity_pool_id = aws_cognito_identity_pool.authenticated_pool.id

  roles = {
    "unauthenticated" = aws_iam_role.guest_role.arn
    "authenticated"   = aws_iam_role.authenticated_role.arn
  }

  role_mapping {
    identity_provider         = "cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.users.id}:${aws_cognito_user_pool_client.site_client.id}"
    ambiguous_role_resolution = "Deny"
    type                      = "Token"
  }
}

# Cognito Domain
resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = var.user_pool_domain_domain
  user_pool_id = aws_cognito_user_pool.users.id
}