provider "aws" {
  alias = "euw1"
  region  = "eu-west-1"
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
