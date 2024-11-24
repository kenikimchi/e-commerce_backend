resource "aws_dynamodb_table" "guest_cart" {
  name         = var.guest_cart_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.guest_cart_hash_key

  range_key = var.guest_cart_range_key

  attribute {
    name = var.guest_cart_hash_key
    type = "S"
  }

  attribute {
    name = var.guest_cart_range_key
    type = "S"
  }
}