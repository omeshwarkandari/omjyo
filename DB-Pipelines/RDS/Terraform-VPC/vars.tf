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

variable "main_vpc_cidr" {}

variable "public_subnets" {}

variable "private_subnets" {}
