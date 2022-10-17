# VPC
resource "aws_vpc" "demo" {
  cidr_block                       = var.cidr_block
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "${var.namespace}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "itg" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "${var.namespace}-itg"
  }

  depends_on = [aws_vpc.demo]
}

# Public Subnets
resource "aws_subnet" "public-subnet" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.namespace}-public-subnet-${count.index + 1}"
  }

  depends_on = [aws_vpc.demo]
}

# Private Subnets
resource "aws_subnet" "private-subnet" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.demo.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.namespace}-private-subnet-${count.index + 1}"
  }

  depends_on = [aws_vpc.demo]
}

# NAT resources: This will create 2 NAT gateways in 2 Public Subnets for 2 different Private Subnets.
# Elastic Ips
resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidr_blocks)
  vpc   = true

  tags = {
    Name = "${var.namespace}-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.itg]
}

# NAT Gateways
resource "aws_nat_gateway" "ntg" {
  count         = length(var.private_subnet_cidr_blocks)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public-subnet[count.index].id

  tags = {
    Name = "${var.namespace}-ntg-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.itg]
}

# This will create both local route as well as route to the internet (0.0.0.0/0)
# Route Table for Public Route
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.demo.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.itg.id
  }

  tags = {
    Name = "${var.namespace}-public-route"
  }

  depends_on = [aws_internet_gateway.itg]
}

# Route Table Association - Public Routes
resource "aws_route_table_association" "public-route-asso" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-route.id

  depends_on = [aws_subnet.public-subnet, aws_route_table.public-route]
}

# Route Table for Private Routes
resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.demo.id
  count  = length(var.private_subnet_cidr_blocks)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ntg[count.index].id
  }

  tags = {
    Name = "${var.namespace}-private-route-${count.index + 1}"
  }

  depends_on = [aws_nat_gateway.ntg]
}

# Route Table Association - Private Routes
resource "aws_route_table_association" "private-route-asso" {
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-route[count.index].id

  depends_on = [aws_subnet.private-subnet, aws_route_table.private-route]
}
