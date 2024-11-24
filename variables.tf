#Cognito
variable "cognito_username_attributes" {
  type = list(string)
}

variable "cognito_verified_attributes" {
  type = list(string)
}

variable "cognito_client_name" {
  type = string
}

variable "cognito_client_callback_urls" {
  type = list(string)
}

variable "user_pool_domain_domain" {
  type = string
}

# DynamoDB
variable "guest_cart_hash_key" {
  type = string
}

variable "guest_cart_range_key" {
  type = string
}

variable "guest_cart_table_name" {
  type = string
}