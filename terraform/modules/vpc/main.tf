data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.no_of_availability_zones)
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "14.${var.second_octet}.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "CGW-${var.environment}-vpc"
  }
}

# Subnets
# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "CGW-${var.environment}-igw"
  }
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
  tags = {
    Name = "CGW-${var.environment}-eip"
  }
}

# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)

  tags = {

    Name = "CGW-${var.environment}-nat"
  }
}
# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(local.availability_zones)
  cidr_block              = "14.${var.second_octet}.${count.index * 16}.0/24"
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {

    Name = "CGW-${var.environment}-${element(local.availability_zones, count.index)}-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(local.availability_zones)
  cidr_block              = "14.${var.second_octet}.${sum([count.index, length(local.availability_zones)]) * 16}.0/24"
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {

    Name = "CGW-${var.environment}-${element(local.availability_zones, count.index)}-private-subnet"
  }
}
# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {

    Name = "CGW-${var.environment}-private-route-table"
  }

}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {

    Name = "CGW-${var.environment}-public-route-table"

  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public" {
  count          = length(local.availability_zones)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(local.availability_zones)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
