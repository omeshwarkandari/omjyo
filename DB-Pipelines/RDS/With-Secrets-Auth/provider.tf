provider "aws" {
  region                  = var.AWS_REGION
  shared_credentials_file = var.shared_credentials_file
  profile                 = var.profile
}
