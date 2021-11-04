variable "project_name" {
  type    = string
  default = "trrfrm"
}

#### Networking section

### CIDR Blocks
variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/22"
}

variable "public_cidr_blocks" {
  type = list(string)
  default = [
    "192.168.0.0/24"
  ]
}

variable "private_cidr_blocks" {
  type = list(string)
  default = [
    "192.168.2.0/24",
    "192.168.3.0/24"
  ]
}

variable "inet_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "client_ip" {
  type    = string
  default = "176.106.217.78/32"
}

### Routing and switching
variable "subnets_config" {
  type = list(object({
    name                            = string
    cidr_block                      = optional(string)
    customer_owned_ipv4_pool        = optional(string)
    ipv6_cidr_block                 = optional(string)
    map_customer_owned_ip_on_launch = optional(bool)
    map_public_ip_on_launch         = optional(bool)
    outpost_arn                     = optional(string)
    assign_ipv6_address_on_creation = optional(bool)
    tags = object({
      Name    = optional(string)
      Project = optional(string)
    })


  }))
}

/*variable "inet_rt_route" { #Explain why in this way!!!!
  type = list(object({
    cidr_block                 = string
    gateway_id                 = string
    carrier_gateway_id         = string
    destination_prefix_list_id = string
    egress_only_gateway_id     = string
    instance_id                = string
    ipv6_cidr_block            = string
    local_gateway_id           = string
    nat_gateway_id             = string
    network_interface_id       = string
    transit_gateway_id = string
    vpc_endpoint_id = string
    vpc_peering_connection_id = string
  }))
  
} 
*/

#### Security 
/*
variable "security_groups" {
  type = list(object({
    name                   = string
    description            = optional(string)
    ingress                = list(string)
    egress                 = list(string)
    name_prefix            = optional(string)
    revoke_rules_on_delete = optional(bool)
    tags                   = optional(string)
  }))
}
*/

variable "ingress_rules" { #Change to rules and add identifier ingress/egress
  type = list(object({
    name                = string
    security_group_type = string
    description         = optional(string)
    from_port           = number
    to_port             = number
    protocol            = string
    cidr_blocks         = optional(list(string))
    security_groups     = optional(list(string))
    ipv6_cidr_blocks    = optional(list(string))
    prefix_list_ids     = optional(string)
    self                = optional(bool)
  }))
}

variable "security_group_rules" {
  type = list(object({
    name                     = string
    security_group_type      = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    type                     = string
    cidr_blocks              = optional(list(string))
    description              = optional(string)
    ipv6_cidr_blocks         = optional(list(string))
    prefix_list_ids          = optional(list(string))
    self                     = optional(bool)
    source_security_group_id = optional(string)
  }))
}


locals {
  subnets_config = defaults(var.subnets_config, {
    map_public_ip_on_launch = true
    tags = {
      Name    = "unnamed"
      Project = "trrfrm"
    }
  })
}



variable "s3_bucket_names" {
  type = list(string)
  default = [
    "bucket-000001",
    "bucket-000002",
    "bucket-000003"
  ]
}