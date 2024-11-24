# Bucket for storing lambda
resource "aws_s3_bucket" "lambda_cart_service_bucket" {
  bucket = var.lambda_cart_service_bucket_name
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_get-cart_assume_role" {
  name = "get-cart_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_get-cart_db_access" {
  name = "LambdaDynamoDBAccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ],
        Resource = var.dynamodb_guest_cart_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_get-cart_policy" {
  role       = aws_iam_role.lambda_get-cart_assume_role.name
  policy_arn = aws_iam_policy.lambda_get-cart_db_access.arn
}