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