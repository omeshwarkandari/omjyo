variable "profile" {
    default = "demo"  
}

variable "region" {
    default = "us-east-1"  
}

variable "bucket_prefix" {
    type        = string
    description = "(required since we are not using 'bucket') Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
    default     = ""
}

variable "acl" {
    type        = string
    description = "(Optional) The canned ACL to apply. Defaults to private. Conflicts with grant."
    default     = "private"
}

variable "versioning" {
    type        = bool
    description = "(Optional) A state of versioning."
    default     = "true"
}

variable "lifecycle_rule" { 
    type = bool
    description = "(Optional) A state of lifecycle." 
    default = "true"  
}

variable "target_bucket" {
    type        = string
    description = "(Required) The name of the bucket that will receive the log objects."
    default     = "omjyo"
}

variable "target_prefix" {
    type        = string
    description = "(Optional) To specify a key prefix for log objects."
    default     = "log/"
}