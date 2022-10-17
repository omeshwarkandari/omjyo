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

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
  type        = list(any)
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
  type        = list(any)
  description = "List of private subnet CIDR blocks"
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b"]
  type        = list(any)
  description = "List of availability zones"
}

variable "namespace" {
  default = "demo"
  nullable = false
}
