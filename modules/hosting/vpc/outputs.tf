output "subnet_availability_zones" {
  value = { for cidr, subnet in aws_subnet.public_subnets : cidr => subnet.availability_zone }
}

