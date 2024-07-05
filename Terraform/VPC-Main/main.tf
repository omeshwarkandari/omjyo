resource "aws_vpc" "dev-vpc" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = "${var.namespace}"
  }
}

#IGW
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "${var.namespace}-igw"
  }
}

resource "aws_subnet" "dev-public-subnets" {
  vpc_id                  = aws_vpc.dev-vpc.id
  count                   = length(var.azs)
  cidr_block              = element(var.dev-public-subnets, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.namespace}-public-subnet-${count.index + 1}"
  }
}


resource "aws_subnet" "dev-private-subnets" {
  vpc_id            = aws_vpc.dev-vpc.id
  count             = length(var.azs)
  cidr_block        = element(var.dev-private-subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.namespace}-private-subnet-${count.index + 1}"
  }
}


#route table for public subnet
resource "aws_route_table" "dev-public-rtable" {
  vpc_id = aws_vpc.dev-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }

  tags = {
    Name = "${var.namespace}-public-rtable"
  }
}

#route table association public subnets
resource "aws_route_table_association" "public-subnet-association" {
  count          = length(var.dev-public-subnets)
  subnet_id      = element(aws_subnet.dev-public-subnets.*.id, count.index)
  route_table_id = aws_route_table.dev-public-rtable.id
}

# EIP
resource "aws_eip" "nat-eip" {
  count = length(var.azs)
  domain = "vpc"

  tags = {
    Name = "${var.namespace}-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.dev-igw]
}

#NAT gateway
resource "aws_nat_gateway" "dev-ngw" {
  count         = length(var.azs)
  allocation_id = element(aws_eip.nat-eip.*.id, count.index)
  subnet_id     = element(aws_subnet.dev-public-subnets.*.id, count.index)

  tags = {
    Name = "${var.namespace}-ngw-${count.index + 1}"
  }
}

#Route table for private subnets
resource "aws_route_table" "dev-private-rtable" {
  vpc_id = aws_vpc.dev-vpc.id
  count  = length(aws_subnet.dev-private-subnets)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.dev-ngw.*.id, count.index)	
  }

  tags = {
    Name = "${var.namespace}-private-rtable-${count.index + 1}"
  }
}

#Route table association for private subnets
resource "aws_route_table_association" "private-subnet-association" {
  count          = length(var.dev-private-subnets)
  subnet_id      = element(aws_subnet.dev-private-subnets.*.id, count.index)
  route_table_id = element(aws_route_table.dev-private-rtable.*.id, count.index)
}
