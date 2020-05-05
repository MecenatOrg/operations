variable log_bucket_name {
  type        = string
  description = "bucket name for s3 logs"
}

variable region {
  type        = string
  description = "aws region"
}

variable tags {
  type        = map
  description = "tags to attach for each resource"
  default     = {}
}