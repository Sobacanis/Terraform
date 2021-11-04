terraform {
  backend "s3" {
    bucket = "ikul-trrfrm"
    key    = "trrfm-second-attempt/terraform.tfstate"
    region = "eu-west-1"

  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
  experiments      = [module_variable_optional_attrs]
}

variable "region" {
  type    = string
  default = "eu-west-1"
}