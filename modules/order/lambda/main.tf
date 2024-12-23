# Bucket for storing lambda
resource "aws_s3_bucket" "lambda_cart_service_bucket" {
  bucket = var.lambda_cart_service_bucket_name
}

resource "aws_s3_bucket_public_access_block" "lambda_cart_service_public_access" {
  bucket = aws_s3_bucket.lambda_cart_service_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "github_actions_policy" {
  bucket = aws_s3_bucket.lambda_cart_service_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGitHubActions"
        Effect = "Allow"
        Principal = {
          AWS = var.github_svc
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.lambda_cart_service_bucket.arn,
          "${aws_s3_bucket.lambda_cart_service_bucket.arn}/*"
        ]
      }
    ]
  })
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

# Lambda Function
resource "aws_lambda_function" "get-cart" {
  function_name = "get-cart"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_get-cart_assume_role.arn
  handler       = "lambda_function.lambda_handler"

  s3_bucket = aws_s3_bucket.lambda_cart_service_bucket.id
  s3_key    = var.get-cart_s3_key

  timeout     = 10
  memory_size = 128
}