resource "aws_dynamodb_table" "guest_cart" {
  name = "guest_cart"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "guestId"

  attribute {
    name = "guestId"
    type = "S"
  }
}