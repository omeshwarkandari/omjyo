resource "aws_vpc" "demo" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.namespace}"
  }
}


resource "aws_subnet" "public-subnet" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.namespace}-public-subnet-${count.index+1}"
  }
}


resource "aws_subnet" "private-subnet" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.demo.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.namespace}-private-subnet-${count.index+1}"
  }
}


resource "aws_internet_gateway" "itg" {
  vpc_id = aws_vpc.demo.id
  tags = {
    Name = "${var.namespace}-itg"
  }
}


### This will create both local route as well as route for 0.0.0.0/0

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.demo.id
  route {
	cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.itg.id
  }
  depends_on = [aws_internet_gateway.itg]
  tags = {
    Name = "${var.namespace}-public-route"
  }
}	

resource "aws_route_table_association" "public-route" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-route.id
}


resource "aws_route_table" "private-route" {
    vpc_id = aws_vpc.demo.id
	count = length(var.private_subnet_cidr_blocks)
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.ntg[count.index].id	
	}
    tags = {
    Name = "${var.namespace}-private-route-${count.index+1}"
  }
}

resource "aws_route_table_association" "private-route" {
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-route[count.index].id
}


# NAT resources: This will create 2 NAT gateways in 2 Public Subnets for 2 different Private Subnets.

resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidr_blocks)
  vpc = true
  tags = {
    Name = "${var.namespace}-eip-${count.index+1}"
  }
}

resource "aws_nat_gateway" "ntg" {
  depends_on = [aws_internet_gateway.itg]
  count = length(var.private_subnet_cidr_blocks)  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public-subnet[count.index].id
  tags = {
    Name = "${var.namespace}-ntg-${count.index+1}"
  }
}
