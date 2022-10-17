resource "aws_vpc" "prod-vpc" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = "prod-vpc"
  }
}

resource "aws_subnet" "prod-private-subnets" {
  vpc_id            = aws_vpc.prod-vpc.id
  count             = length(var.azs)
  cidr_block        = element(var.prod-private-subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "prod-private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "prod-public-subnets" {
  vpc_id            = aws_vpc.prod-vpc.id
  count             = length(var.azs)
  cidr_block        = element(var.prod-public-subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "prod-public-subnet-${count.index + 1}"
  }
}

#IGW
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-igw"
  }
}

#route table for public subnet
resource "aws_route_table" "prod-public-rtable" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-public-rtable"
  }
}

#add routes to public-rtable this is just for testing
resource "aws_route" "ner-subnets-public-rtable" {
  count                  = length(var.public-subnets)
  route_table_id         = aws_route_table.prod-public-rtable.id
  destination_cidr_block = element(var.public-subnets, count.index)
  gateway_id             = aws_internet_gateway.prod-igw.id
}

#route table association public subnets
resource "aws_route_table_association" "public-subnet-association" {
  count          = length(var.prod-public-subnets)
  subnet_id      = element(aws_subnet.prod-public-subnets.*.id, count.index)
  route_table_id = aws_route_table.prod-public-rtable.id
}

#EIP
resource "aws_eip" "nat-eip" {
  count = length(var.azs)
  vpc   = true

  tags = {
    Name = "EIP--${count.index + 1}"
  }
}

#NAT gateway
resource "aws_nat_gateway" "prod-nat-gateway" {
  count         = length(var.azs)
  allocation_id = element(aws_eip.nat-eip.*.id, count.index)
  subnet_id     = element(aws_subnet.prod-public-subnets.*.id, count.index)

  tags = {
    Name = "NAT-GW--${count.index + 1}"
  }
}
