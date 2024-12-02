# output "nat_gateway_map" {
#   value = { for subnet_id, nat in aws_nat_gateway.public_nat_gw : subnet.id => nat.id }
# }