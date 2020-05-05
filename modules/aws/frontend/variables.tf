variable cnames {
  type        = list(string)
  description = "provide cnames (aliases) for cloudfront distribution"
  default     = []
}

variable region {
  type        = string
  description = "aws region"
}

variable s3_origin_id {
  type        = string
  description = "set unique origin id for s3 in cloudfront"
  default     = "S3ID"
}

variable log_bucket_frontend {
  type        = any 
  description = "log bucket for frontend "
}
variable log_bucket_cloudfront {
  type        = any 
  description = "log bucket for cloudfornt "
}


variable certificate_arn {
  type = string
  description = "arn of the certificate"
  
}



variable origin_bucket_name {
  type        = string
  description = "s3 origin bucket name"
}

variable origin_logs_prefix {
  type        = string
  description = "prefix for origin logs"
  default     = "origin/"
}

variable cloudfront_logs_prefix {
  type        = string
  description = "prefix for cloudfront logs"
  default     = "cloudfront/"
}

variable tags {
  type        = map
  description = "tags to attach for each resource"
  default     = {}
}
