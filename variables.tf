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

#### Security section

variable "security_groups" {
  type = list(object({
    name                   = string
    description            = optional(string)
    ingress                = optional(list(string))
    egress                 = optional(list(string))
    name_prefix            = optional(list(string))
    revoke_rules_on_delete = optional(bool)
    tags                   = optional(list(string))
    default_tags           = optional(list(string))
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


#### Database section

variable "db_parmater_groups" {
  type = list(object({
    name        = string
    family      = string
    description = optional(string)
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string) ###"immediate" (default), or "pending-reboot"
    })))
  }))
}