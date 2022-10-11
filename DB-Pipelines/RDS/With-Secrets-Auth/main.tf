resource "aws_vpc" "demo-vpc" {
  cidr_block           = "10.50.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    Name = "demo-vpc"
  }
}


resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = "10.50.1.0/24"
  availability_zone       = "${var.AWS_REGION}a"
  map_public_ip_on_launch = "true"
  tags = {
    "Name" = "public-subnet1"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = "10.50.2.0/24"
  availability_zone       = "${var.AWS_REGION}b"
  map_public_ip_on_launch = "true"
  tags = {
    "Name" = "public-subnet2"
  }
}


resource "aws_subnet" "private-subnet1" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = "10.50.3.0/24"
  availability_zone = "${var.AWS_REGION}c"
  tags = {
    "Name" = "private-subnet1"
  }
}

resource "aws_subnet" "private-subnet2" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = "10.50.4.0/24"
  availability_zone = "${var.AWS_REGION}d"
  tags = {
    "Name" = "private-subnet2"
  }
}


resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id
  tags = {
    "Name" = "demo-itg"
  }
}


resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }
  tags = {
    "Name" = "public-rt"
  }
}

resource "aws_route_table_association" "public-rt-asso1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-rt-asso2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public-rt.id
}


resource "aws_eip" "nat-eip" {
  vpc = "true"
}

resource "aws_nat_gateway" "demo-nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet1.id
  depends_on    = [aws_internet_gateway.demo-igw]
  tags = {
    "Name" = "demo-nat"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.demo-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.demo-nat.id
  }
  tags = {
    "Name" = "private-rt"
  }
}

resource "aws_route_table_association" "private-asso1" {
  subnet_id      = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-asso2" {
  subnet_id      = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.private-rt.id
}


resource "aws_network_acl" "demo-acl" {
  vpc_id     = aws_vpc.demo-vpc.id
  subnet_ids = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id, aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id]
  ingress {
    rule_no    = "100"
    action     = "allow"
    protocol   = "tcp"
    from_port  = "80"
    to_port    = "80"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = "200"
    action     = "allow"
    protocol   = "tcp"
    from_port  = "1024"
    to_port    = "65535"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = "300"
    action     = "allow"
    protocol   = "tcp"
    from_port  = "22"
    to_port    = "22"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = "100"
    action     = "allow"
    protocol   = "tcp"
    from_port  = "80"
    to_port    = "80"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = "200"
    action     = "allow"
    protocol   = "tcp"
    from_port  = "1024"
    to_port    = "65535"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = "300"
    action     = "allow"
    protocol   = "tcp"
    from_port  = "22"
    to_port    = "22"
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_security_group" "web-sg" {
  vpc_id      = aws_vpc.demo-vpc.id
  name        = "webserver-sg"
  description = "Security Group for the Bastion Host Instance"
  tags = {
    "Name" = "Webserver-SG"
  }

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webserver1" {
  ami                    = var.amis
  instance_type          = var.instance_type
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  key_name               = "test"
  user_data              = file("script.sh")
  subnet_id              = aws_subnet.public-subnet1.id
  tags = {
    "Name" = "baston_host"
  }
}


resource "aws_security_group" "db-sg" {
  vpc_id      = aws_vpc.demo-vpc.id
  description = "Security Group for the mysqldb instance"
  tags = {
    "Name" = "Database-sg"
  }

  ingress {
    from_port   = "3306"
    to_port     = "3306"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_db_subnet_group" "db-subnet" {
  name       = "db-subnet"
  subnet_ids = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id]
}

resource "aws_db_instance" "mysqldb" {
  identifier             = "mydb"
  count                  = "1"
  allocated_storage      = "10"
  max_allocated_storage  = "30"
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               =  var.db_username
  password               =  var.db_password
  skip_final_snapshot    = "true"
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.id
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  db_name                = "demodb"
}