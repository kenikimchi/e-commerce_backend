# NAT Gateway
resource "aws_eip" "eip-nat" {
  count = length(var.public_subnet_ids)

  domain = "vpc"
}

resource "aws_nat_gateway" "public_nat_gw" {
  count = length(var.public_subnet_ids)

  allocation_id = aws_eip.eip-nat[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]
}

locals {
  private_route_table_map = {
    element(var.private_subnet_cidrs, 0) = aws_nat_gateway.public_nat_gw[0].id
    element(var.private_subnet_cidrs, 1) = aws_nat_gateway.public_nat_gw[0].id
    element(var.private_subnet_cidrs, 2) = aws_nat_gateway.public_nat_gw[1].id
    element(var.private_subnet_cidrs, 3) = aws_nat_gateway.public_nat_gw[1].id
  }
}

resource "aws_route_table" "private_route_tables" {
  for_each = local.private_route_table_map

  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value
  }
}