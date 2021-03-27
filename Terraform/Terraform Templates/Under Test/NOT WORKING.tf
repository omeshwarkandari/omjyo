provider "aws" {
    profile = "${var.profile}"
    region = "${var.region}"  
}

resource "aws_instance" "demo_instance" {
    vpc_security_group_ids = [ "sg-0e260c4457c6c1b54" ]
    ami = "ami-0915bcb5fa77e4892"    
    key_name = "demokeypair"
    instance_type = "t2.micro"  
    provisioner "file" {    
        source = "script.sh"
        destination = "/tmp/script.sh"    
    }

    provisioner "remote-exec" {
        inline = [ 
        "chmod +x /tmp/script.sh",
        "sudo /tmp/script.sh"
        ]    
    }        
    
    connection {
        host = "${aws_instance.demo_instance.public_ip}"
        user = "ec2-user"
        private_key = "${file("${var.private_key_path}")}"     
    }
}
   