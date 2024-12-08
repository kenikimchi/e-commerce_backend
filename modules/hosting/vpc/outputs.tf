output "subnet_availability_zones" {
  value = { for cidr, subnet in aws_subnet.public_subnets : cidr => subnet.availability_zone }
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnet : subnet.id]
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public_subnets : subnet.id]
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_a_id" {
  value = aws_subnet.private_subnet[0].id
}

output "private_subnet_b_id" {
  value = aws_subnet.private_subnet[1].id
}