locals {
  public_subnet_id = aws_subnet.vpc_subnets["192.168.0.0/24"].id ###Is it ok?
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

locals {
  inet_route = {
    cidr_block                 = var.inet_cidr
    gateway_id                 = aws_internet_gateway.igw.id
    carrier_gateway_id         = null
    destination_prefix_list_id = null
    egress_only_gateway_id     = null
    instance_id                = null
    ipv6_cidr_block            = null
    local_gateway_id           = null
    nat_gateway_id             = null
    network_interface_id       = null
    transit_gateway_id         = null
    vpc_endpoint_id            = null
    vpc_peering_connection_id  = null
  }
}

