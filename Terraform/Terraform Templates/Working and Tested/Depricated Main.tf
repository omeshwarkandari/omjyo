
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
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "public-subnet1"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  cidr_block = "10.50.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    "Name" = "public-subnet2"
  }
}

resource "aws_subnet" "public-subnet3" {  
  vpc_id =  "${aws_vpc.demo-vpc.id}"
  cidr_block = "10.50.3.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = "true"
  tags = {
    "Name" = "BasionHost-subnet"
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

resource "aws_route_table_association" "public-rt-asso3" {  
  subnet_id = "${aws_subnet.public-subnet3.id}"
  route_table_id =  "${aws_route_table.public-rt.id}"  
}


resource "aws_network_acl" "demo-acl" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  subnet_ids = [ "${aws_subnet.public-subnet1.id}" , "${aws_subnet.public-subnet2.id}" , "${aws_subnet.public-subnet3.id}"]

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
  name = "webserver-sg"
  description = "Security Group for the Webservers"
  tags = {
    "Name" = "Webserver-SG"
  }

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

resource "aws_security_group" "lb-sg" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  description = "Security Group for the Load Balancer"
  tags = {
    "Name" = "Loadbalancer-sg"
  }
  
  ingress {
    from_port = "80"
    to_port = "80"
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

resource "aws_security_group" "db-sg" { 
  vpc_id = "${aws_vpc.demo-vpc.id}"
  description = "Security Group for the mysqldb instance" 
  tags = {
    "Name" = "Database-sg"
  }
  
  ingress  {
    from_port = "3306"
    to_port = "3306"
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
  user_data = "${file("script1.sh")}"
  depends_on = [ aws_internet_gateway.demo-igw ]
  subnet_id = "${aws_subnet.public-subnet1.id}"
  tags = {
    "Name" = "webserver1"
  }
}

resource "aws_instance" "webserver2" {
  ami = "ami-0915bcb5fa77e4892"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.web-sg.id}" ]
  key_name = "demokeypair"
  user_data = "${file("script2.sh")}"
  depends_on = [ aws_internet_gateway.demo-igw ]
  subnet_id = "${aws_subnet.public-subnet2.id}"
  tags = {
    "Name" = "webserver2"
  }
}

resource "aws_instance" "Basion-Host" { 
  ami = "ami-0915bcb5fa77e4892"
  instance_type = "t2.micro"
  key_name = "demokeypair"
  subnet_id = "${aws_subnet.public-subnet3.id}"
  vpc_security_group_ids = [ "${aws_security_group.web-sg.id}" ]
  tags = {
    "Name" = "Bastion-Host"
  }  
}

resource "aws_lb" "web-lb" {
  internal =  "false"
  load_balancer_type = "application"
  subnets = ["${aws_subnet.public-subnet1.id}","${aws_subnet.public-subnet2.id}"]
  security_groups = ["${aws_security_group.lb-sg.id}"] 
  tags = {
    "Name" = "Web-LoadBalancer"
  } 
  access_logs { 
    bucket = aws_s3_bucket.omjyo1.id
    prefix = "log"  
    enabled = "true"        
  }
}

resource "aws_lb_listener" "lb-listner" {
  load_balancer_arn = "${aws_lb.web-lb.arn}"
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.web-tg.arn}"    
  }    
}

resource "aws_lb_target_group" "web-tg" {
  name = "web-tg"
  port = "80"
  protocol = "HTTP"
  vpc_id = "${aws_vpc.demo-vpc.id}"
}

resource "aws_lb_target_group_attachment" "web-tg-attach1" {
  target_group_arn = "${aws_lb_target_group.web-tg.arn}"
  target_id = "${aws_instance.webserver1.id}"
  port = "80"  
}

resource "aws_lb_target_group_attachment" "web-tg-attach2" {
  target_group_arn = "${aws_lb_target_group.web-tg.arn}"
  target_id = "${aws_instance.webserver2.id}"
  port = "80"  
}

resource "aws_db_subnet_group" "db-subnet" {
  name = "db-subnet"
  subnet_ids = [ "${aws_subnet.public-subnet1.id}" , "${aws_subnet.public-subnet2.id}" ] 
}

resource "aws_db_instance" "mysqldb" { 
  allocated_storage = "10" 
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7.26"
  instance_class = "db.t2.micro"
  username = "test"
  password = "password" 
  skip_final_snapshot = "true"    
  db_subnet_group_name = "${aws_db_subnet_group.db-subnet.id}"
  vpc_security_group_ids = [ "${aws_security_group.db-sg.id}" ] 
  name = "demodb"
}

resource "aws_s3_bucket" "omjyo1" {
  bucket = "omjyo1" 
  acl = "public-read-write" 
  versioning {
    enabled = "true"
    }
  lifecycle_rule {
    enabled = "true"
    expiration {
      days = "2"
      }
    }
    force_destroy = "true"   
}

resource "aws_s3_bucket" "s3-bucket" { 
    bucket = "omjyo"    
    acl = "private"

    versioning {
      enabled = "true"
    }

    logging { 
        target_bucket = "${aws_s3_bucket.omjyo1.id}" 
        target_prefix = "/log"       
    } 

    lifecycle_rule { 
        enabled = "true" 
        expiration {
        days = "1" 
        }        
    } 
    force_destroy = "true" 
}