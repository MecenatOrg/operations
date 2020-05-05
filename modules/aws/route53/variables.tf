variable "route_53_name" {
  type        = string
  description = "Name of the hosted zone"
}
variable "record_name" {
  type        = string
  description = "Record name"
}

variable "alias_record_name" {
  type        = "string"
  description = "DNS domain name for a CloudFront distribution, S3 bucket, ELB, or another resource record set in this hosted zone. "

}
variable "alias_zone_id" {
  type        = "string"
  description = "Hosted zone ID for a CloudFront distribution, S3 bucket, ELB, or Route 53 hosted zone."

}

