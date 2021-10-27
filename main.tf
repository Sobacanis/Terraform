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
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"
  # Do you usually define versions of services?
  name = "${var.project["project_name"]}-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.az-available.names
  private_subnets = slice(var.private_cidr_blocks, 0, var.project["private_subnets_per_vpc"])
  public_subnets  = slice(var.public_cidr_blocks, 0, var.project["public_subnets_per_vpc"])

  enable_nat_gateway = false
  enable_vpn_gateway = false
  tags = {
    project = var.project["project_name"]
  }
}

module "public_security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "4.4.0"
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
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = {
    project = var.project["project_name"]
  }
}

module "private_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"
  name    = "${var.project["project_name"]}-private-sg"
  vpc_id  = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.public_security_group.security_group_id
    }
  ]
  tags = {
    project = var.project["project_name"]
  }
}

####Compute section

data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

module "ec2_linux" {
  # Is there any reason to use modules everywhere, or it's better to use "resource" here?
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "3.2.0"
  name                   = "linux_instance"
  ami                    = data.aws_ami.amazon_ami.id
  instance_type          = "t2.micro"
  key_name               = "my-keypair-01"
  vpc_security_group_ids = [module.public_security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  tags = {
    name    = "ec2-linux"
    project = var.project["project_name"]
  }

}

####Database section

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "aws_db_subnet_group" "dbsubnet_group" {
  name       = "db_subnet_group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    name    = "DB subnetgroup"
    project = var.project["project_name"]
  }
}
module "db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "3.4.0"
  identifier = "${var.project["project_name"]}-db"

  engine               = var.project["dbengine"]
  engine_version       = var.project["dbengine_version"]
  major_engine_version = var.project["dbmajor_engine_version"]
  family               = var.project["dbparametergroup_family"]
  instance_class       = var.project["dbinstance_class"]
  allocated_storage    = var.project["dballocated_storage"]

  name     = "${var.project["project_name"]}db"
  username = var.project["dbadmin"]
  password = random_password.db_password.result
  port     = var.project["dbport"]

  vpc_security_group_ids = [module.private_security_group.security_group_id]

  multi_az = true

  backup_retention_period = 1
  skip_final_snapshot     = true

  tags = {
    project = var.project["project_name"]
  }

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet_group.name

  # Database Deletion Protection
  deletion_protection = false

}

module "db_read_replica" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.4.0"

  identifier = "${var.project["project_name"]}-replica"

  replicate_source_db = module.db.db_instance_id

  engine               = var.project["dbengine"]
  engine_version       = var.project["dbengine_version"]
  major_engine_version = var.project["dbmajor_engine_version"]
  family               = var.project["dbparametergroup_family"]
  instance_class       = var.project["dbinstance_class"]
  allocated_storage    = var.project["dballocated_storage"]

  username = null
  password = null
  port     = var.project["dbport"]

  vpc_security_group_ids = [module.private_security_group.security_group_id]

  multi_az = false

  backup_retention_period = 0
  skip_final_snapshot     = true

  create_db_subnet_group = false

  tags = {
    project = var.project["project_name"]
  }

  # Database Deletion Protection
  deletion_protection = false

}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "rds_credentials"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
{
  "username": "${module.db.db_instance_username}",
  "password": "${random_password.db_password.result}",
  "engine": "mysql",
  "host": "${module.db.db_instance_address}",
  "port": "${module.db.db_instance_port}"
}
EOF
}

####Storage section
module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.9.0"

  count         = length(var.s3_bucket_names)
  bucket        = var.s3_bucket_names[count.index]
  acl           = "private"
  force_destroy = true
}