variable "AWS_REGION" {
  default     = "us-east-1"
  description = "Default AWS Region"
}

variable "shared_credentials_file" {
  default     = "/home/ec2-user/.aws/credentials"
  description = "Sahred Credentials File Location"
}

variable "profile" {
  default     = "default"
  description = "Name of the Profile"
}


variable "instance_type" {
  default = "t2.micro"
}


variable "amis" {
  default = "ami-0915bcb5fa77e4892"
}


variable "db_instance_class" {
  default = "db.t2.micro"
}


variable "storage_type" {
  default = "gp2"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
