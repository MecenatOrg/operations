locals {
  domain_name_development= "development.mecenat.com.ua"
  hosted_zone_name_development = "mecenat.com.ua"
  region_frontend_development  = "eu-west-1"
  region_cloudfront_development="us-east-1"
  prefix_development="development_web_mecenat" 
} 
module "log_bucket_frontend_development" {
  source = "./modules/aws/logBucket"
  log_bucket_name="eu-west-1.mecenat-development.log"
  region= local.region_frontend_development
   providers = {
    aws = "aws.euw1"
  }
}
module "log_bucket_cloudfront_development" {
  source = "./modules/aws/logBucket"
  log_bucket_name="us-east-1.mecenat-development.log"
  region= local.region_cloudfront_development
   providers = {
    aws = "aws.use1"
  }
}
module "certificates_development" {
  source = "./modules/aws/certificate"
  domain= local.domain_name_development
  sld=true
  providers = {
    aws = "aws.use1"
  }
}
module "frontend_development" {
  source = "./modules/aws/frontend"
  origin_bucket_name = local.domain_name_development
  cloudfront_logs_prefix=local.prefix_development
  origin_logs_prefix=local.prefix_development
  s3_origin_id=local.domain_name_development
  region=local.region_frontend_development
  certificate_arn = module.certificates_development.certificate
  cnames=[local.domain_name_development]
  
  log_bucket_frontend= module.log_bucket_frontend_development.log_bucket
  log_bucket_cloudfront= module.log_bucket_cloudfront_development.log_bucket
  providers = {
    aws = "aws.euw1"
  } 
}

module "Arecord_development" {
  source = "./modules/aws/route53"
  route_53_name = "${local.hosted_zone_name_development}"
  record_name = "${local.domain_name_development}"
  alias_record_name= module.frontend_development.cloudfront_distribution.domain_name
  alias_zone_id =  module.frontend_development.cloudfront_distribution.hosted_zone_id
  providers = {
    aws = "aws.use1"
  } 
}


