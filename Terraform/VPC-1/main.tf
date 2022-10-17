resource "aws_vpc" "demo" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.namespace}"
  }
}


resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.namespace}-public-${count.index+1}"
  }
}


resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.demo.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.namespace}-private-${count.index+1}"
  }
}


resource "aws_internet_gateway" "itg" {
  vpc_id = aws_vpc.demo.id
  tags = {
    Name = "${var.namespace}-itg"
  }
}


### This will create both local route as well as route for 0.0.0.0/0

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.demo.id
  route {
	cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.itg.id
  }
  depends_on = [aws_internet_gateway.itg]
  tags = {
    Name = "${var.namespace}-public_rt}"
  }
}	

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.demo.id
	count = length(var.private_subnet_cidr_blocks)
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.ntg[count.index].id	
	}
    tags = {
    Name = "${var.namespace}-private_rt}"
  }
}

resource "aws_route_table_association" "private_rt" {
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}


# NAT resources: This will create 2 NAT gateways in 2 Public Subnets for 2 different Private Subnets.

resource "aws_eip" "nat" {
  count = 2
  vpc = true
  tags = {
    Name = "${var.namespace}-eip-${count.index+1}"
  }
}

resource "aws_nat_gateway" "ntg" {
  depends_on = [aws_internet_gateway.itg]
  count = 2  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.namespace}-ntg-${count.index+1}"
  }
}
