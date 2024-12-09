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
  value = [for subnet in aws_subnet.private_subnet : subnet.id][0]
}

output "private_subnet_b_id" {
  value = [for subnet in aws_subnet.private_subnet : subnet.id][1]
}