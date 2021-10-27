variable "region" {
  default = "eu-west-1"
}

variable "project" {
  description = "Map for project configuration"
  type        = map(any)
  default = {
    project_name            = "trrfrm",
    public_subnets_per_vpc  = 1,
    private_subnets_per_vpc = 2,
    instance_type           = "t2.micro"
    admin_ip                = "176.106.217.78/32"
    dbadmin                 = "admin"
    dbengine                = "mysql"
    dbengine_version        = "8.0.23"
    dbmajor_engine_version  = "8.0"
    dbparametergroup_family = "mysql8.0"
    dbinstance_class        = "db.t2.micro"
    dballocated_storage     = 5
    dbport                  = "3306"
  }
}

variable "vpc_cidr" {
  default = "192.168.0.0/22"
}

variable "public_cidr_blocks" {
  type = list(string)
  default = [
    "192.168.0.0/24",
    "192.168.1.0/24"
  ]
}

variable "private_cidr_blocks" {
  type = list(string)
  default = [
    "192.168.2.0/24",
    "192.168.3.0/24"
  ]
}

variable "s3_bucket_names" {
  type = list(string)
  default = [
    "bucket-000001",
    "bucket-000002",
    "bucket-000003"
  ]
}