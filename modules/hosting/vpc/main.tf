# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.main_cidr_block
  enable_dns_hostnames = true

  tags = {
    terraform = "true"
    Name      = "${var.project_name}-vpc"
  }
}

# Get availability zones in region
data "aws_availability_zones" "availability_zones" {}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.main.id

  for_each          = toset(var.public_subnet_cidrs)
  cidr_block        = each.value
  availability_zone = element(data.aws_availability_zones.availability_zones.names, index(var.public_subnet_cidrs, each.value))
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Route Tables
resource "aws_route_table" "public_route_tables" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
}

# Associate route tables
resource "aws_route_table_association" "public_rt_associations" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_tables.id
}

# Private Subnets
locals {
  private_cidr_az_map = {
    element(var.private_subnet_cidrs, 0) = aws_subnet.public_subnets["10.10.10.0/24"].availability_zone
    element(var.private_subnet_cidrs, 1) = aws_subnet.public_subnets["10.10.10.0/24"].availability_zone
    element(var.private_subnet_cidrs, 2) = aws_subnet.public_subnets["10.10.11.0/24"].availability_zone
    element(var.private_subnet_cidrs, 3) = aws_subnet.public_subnets["10.10.11.0/24"].availability_zone
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main.id

  for_each                = local.private_cidr_az_map
  cidr_block              = each.key
  availability_zone       = each.value
  map_public_ip_on_launch = false
}

