locals {
  domain_name_staging= "staging.mecenat.com.ua"
  hosted_zone_name_staging = "mecenat.com.ua"
  region_frontend_staging  = "eu-west-1"
  region_cloudfront_staging="us-east-1"
  prefix_staging="staging_web_mecenat" 
} 
module "log_bucket_frontend_staging" {
  source = "./modules/aws/logBucket"
  log_bucket_name="eu-west-1.mecenat-staging.log"
  region= local.region_frontend_staging
   providers = {
    aws = "aws.euw1"
  }
}
module "log_bucket_cloudfront_staging" {
  source = "./modules/aws/logBucket"
  log_bucket_name="us-east-1.mecenat-staging.log"
  region= local.region_cloudfront_staging
   providers = {
    aws = "aws.use1"
  }
}
module "certificates_staging" {
  source = "./modules/aws/certificate"
  domain= local.domain_name_staging
  sld=true
  providers = {
    aws = "aws.use1"
  }
}
module "frontend_staging" {
  source = "./modules/aws/frontend"
  origin_bucket_name = local.domain_name_staging
  cloudfront_logs_prefix=local.prefix_staging
  origin_logs_prefix=local.prefix_staging
  s3_origin_id=local.domain_name_staging
  region=local.region_frontend_staging
  certificate_arn = module.certificates_staging.certificate
  cnames=[local.domain_name_staging]
  
  log_bucket_frontend= module.log_bucket_frontend_staging.log_bucket
  log_bucket_cloudfront= module.log_bucket_cloudfront_staging.log_bucket
  providers = {
    aws = "aws.euw1"
  } 
}

module "Arecord_staging" {
  source = "./modules/aws/route53"
  route_53_name = "${local.hosted_zone_name_staging}"
  record_name = "${local.domain_name_staging}"
  alias_record_name= module.frontend_staging.cloudfront_distribution.domain_name
  alias_zone_id =  module.frontend_staging.cloudfront_distribution.hosted_zone_id
  providers = {
    aws = "aws.use1"
  } 
}


