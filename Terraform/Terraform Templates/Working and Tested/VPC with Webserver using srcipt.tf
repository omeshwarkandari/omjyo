provider "aws" {
    profile = "demo"
    region = "us-east-1"  
}

resource "aws_vpc" "demo-vpc" {
    cidr_block = "10.50.0.0/16"
    tags = {
      "Name" = "demo-vpc"
    }
} 

resource "aws_subnet" "public-subnet1" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  cidr_block = "10.50.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    "Name" = "public-subnet1"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  cidr_block = "10.50.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"
  tags = {
    "Name" = "public-subnet2"
  }
}

resource "aws_internet_gateway" "demo-igw" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  tags = {
    "Name" = "MY-GTW"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demo-igw.id}"
  } 
  tags = {
    "Name" = "public-rt"
  }
}

resource "aws_route_table_association" "public-rt-asso1" { 
  subnet_id = "${aws_subnet.public-subnet1.id}"
  route_table_id = "${aws_route_table.public-rt.id}"  
}

resource "aws_route_table_association" "public-rt-asso2" { 
  subnet_id = "${aws_subnet.public-subnet2.id}"
  route_table_id = "${aws_route_table.public-rt.id}"  
}


resource "aws_network_acl" "demo-acl" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  subnet_ids = [ "${aws_subnet.public-subnet1.id}" , "${aws_subnet.public-subnet2.id}"]
  ingress {
    rule_no = "100"
    action = "allow"
    protocol = "tcp"
    from_port = "80"     
    to_port = "80"
    cidr_block = "0.0.0.0/0"
  } 
  
  ingress {
    rule_no = "200"
    action = "allow"
    protocol = "tcp"
    from_port = "1024"     
    to_port = "65535"
    cidr_block = "0.0.0.0/0"
  } 

  ingress {
    rule_no = "300"
    action = "allow"
    protocol = "tcp"
    from_port = "22"     
    to_port = "22"
    cidr_block = "0.0.0.0/0"
  } 

  egress {
    rule_no = "100"
    action = "allow"
    protocol = "tcp"
    from_port = "80"     
    to_port = "80"
    cidr_block = "0.0.0.0/0"
  } 

  egress {
    rule_no = "200"
    action = "allow"
    protocol = "tcp"
    from_port = "1024"     
    to_port = "65535"
    cidr_block = "0.0.0.0/0"
  } 

  egress {
    rule_no = "300"
    action = "allow"
    protocol = "tcp"
    from_port = "22"     
    to_port = "22"
    cidr_block = "0.0.0.0/0"
  } 
}

resource "aws_security_group" "web-sg" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  description = "Security Group for the Webservers"
  name = "web-sg"
  
  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webserver1" {
  ami = "ami-0915bcb5fa77e4892"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.web-sg.id}" ]
  key_name = "demokeypair"
  user_data = "${file("script.sh")}"
  subnet_id = "${aws_subnet.public-subnet1.id}"
  tags = {
    "Name" = "Webserver1"
  }
}

resource "aws_instance" "webserver2" {
  ami = "ami-0915bcb5fa77e4892"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.web-sg.id}" ]
  key_name = "demokeypair"
  user_data = "${file("script2.sh")}"
  subnet_id = "${aws_subnet.public-subnet2.id}"
  tags = {
    "Name" = "Webserver2"
  }
}
