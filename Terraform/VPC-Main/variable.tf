
variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Region of the VPC"
}

variable "shared_credentials_file" {
  default     = "~/.aws/credentials"
  description = "Sahred Credentials File Location"
}

variable "profile" {
  default     = "default"
  description = "Name of the Profile"
}

variable "vpc-cidr" {
  default = "10.22.0.0/16"
}

variable "azs" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b"]
}


variable "dev-public-subnets" {
  type    = list(any)
  default = ["10.22.8.0/24", "10.22.9.0/24"]
}

variable "dev-private-subnets" {
  type    = list(any)
  default = ["10.22.16.0/24", "10.22.17.0/24"]
}

variable "namespace" {
  default  = "dev"
  nullable = false
}

variable "public_key" {
  type    = string
  default = "test"
}
