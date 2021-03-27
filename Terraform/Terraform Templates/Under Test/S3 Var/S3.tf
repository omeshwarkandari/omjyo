provider "aws" {
    profile = var.profile
    region = var.region 
}

resource "aws_s3_bucket" "omjyo" {

    bucket_prefix = var.bucket_prefix
        acl  = var.acl

    versioning {
        enabled = var.versioning
    }

    lifecycle_rule { 
        enabled = var.lifecycle_rule
        expiration {    
            days = "1"        
        }
    }

    logging {
        target_bucket = var.target_bucket
        target_prefix = var.target_prefix
    }
}
    