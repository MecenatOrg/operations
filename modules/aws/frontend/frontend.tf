
resource "aws_s3_bucket" "frontend" {
  bucket = var.origin_bucket_name
  region = var.region
  tags   = var.tags

  acl           = "private"
  force_destroy = true

  logging {
    target_prefix = var.origin_logs_prefix
    target_bucket = var.log_bucket_frontend.id
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "PolicyForCloudFrontPrivateContent",
  "Statement": [ {
          "Sid": "1",
          "Effect": "Allow",
          "Principal": {
              "AWS": "${aws_cloudfront_origin_access_identity.default.iam_arn}"
          },
          "Action": "s3:GetObject",
          "Resource": "${aws_s3_bucket.frontend.arn}/*"
      }
  ]
}
POLICY
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "OAI for cloudfront access"
}

resource "aws_cloudfront_distribution" "frontend_distribution" {
  aliases             = var.cnames
  enabled             = true
  is_ipv6_enabled     = true
  wait_for_deployment = false
  default_root_object = "/index.html"
  depends_on          = [aws_s3_bucket.frontend]
  comment             = "Distribution for Frontend"

  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = var.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = var.s3_origin_id
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  custom_error_response {
    error_code            = "404"
    response_code         = "200"
    error_caching_min_ttl = "300"
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_code            = "403"
    response_code         = "200"
    error_caching_min_ttl = "300"
    response_page_path    = "/index.html"
  }

  logging_config {
    prefix          = var.cloudfront_logs_prefix
    include_cookies = false
    bucket          = var.log_bucket_cloudfront.bucket_domain_name
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn  = var.certificate_arn
    ssl_support_method= "sni-only"
  }
}

output "frontend_bucket_arn" {
  value       = "${aws_s3_bucket.frontend.arn}"
  description = "s3 bucket with frontend arn"
}
output "cloudfront_distribution" {
  value = "${aws_cloudfront_distribution.frontend_distribution}"
  description = "cloudfornt distribution object"
}
