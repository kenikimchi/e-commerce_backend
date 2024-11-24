resource "aws_apigatewayv2_api" "order" {
  name          = "order"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "guest" {
  api_id = aws_apigatewayv2_api.order.id

  name        = "guest"
  auto_deploy = true

  # access_log_settings
}

resource "aws_apigatewayv2_integration" "get_cart" {
  api_id           = aws_apigatewayv2_api.order.id
  integration_type = "AWS_PROXY"

  integration_method = "GET"
  integration_uri    = var.get_cart_integration_uri
}

resource "aws_apigatewayv2_route" "get_cart" {
  api_id    = aws_apigatewayv2_api.order.id
  route_key = "GET /cart"
  target    = "integrations/${aws_apigatewayv2_integration.get_cart.id}"
}

