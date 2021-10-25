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
    admin_ip = "176.106.217.78/32"
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

variable "db_sg_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access"
    },
    {
      from_port   = 3308
      to_port     = 3308
      protocol    = "tcp"
      description = "SSH access"
    }

  ]
}

variable "app_sg_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "SSH access"
    }

  ]
}