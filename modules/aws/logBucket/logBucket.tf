resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket_name
  region = var.region
  tags   = var.tags

  acl           = "log-delivery-write"
  force_destroy = true

  lifecycle_rule {
    id      = "log"
    enabled = true
    transition {
      days = 30
      # ONEZONE_IA possible here
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

output "log_bucket" {
  value       = "${aws_s3_bucket.log_bucket}"
  description = "s3 log bucket"
}
