terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

data "aws_availability_zones" "az-available" {
  state = "available"
}

####Networking section

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # Do you usually define versions of services?
  name = "${var.project["project_name"]}-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.az-available.names
  private_subnets = slice(var.public_cidr_blocks, 0, var.project["private_subnets_per_vpc"])
  public_subnets  = slice(var.public_cidr_blocks, 0, var.project["public_subnets_per_vpc"])

  enable_nat_gateway = false
  enable_vpn_gateway = false
}

module "public_security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  name                = "${var.project["project_name"]}-public-sg"
  description         = "Inbound HTTP/HTTPS for all, SSH for my IP"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.project["admin_ip"] # Looks a little bit patsavato and unscalable. Change to list of IPs in the future
    }
  ]
}

module "private_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  name   = "${var.project["project_name"]}-private-sg"
  vpc_id = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.public_security_group.security_group_id
    }
  ]
}