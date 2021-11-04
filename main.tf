data "aws_availability_zones" "az-available" {
  state = "available"
}

####Networking section

###Switching
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "vpc_subnets" {
  for_each                        = { for subnets in var.subnets_config : subnets.cidr_block => subnets }
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = each.value.cidr_block
  customer_owned_ipv4_pool        = each.value.customer_owned_ipv4_pool
  ipv6_cidr_block                 = each.value.ipv6_cidr_block
  map_customer_owned_ip_on_launch = each.value.map_customer_owned_ip_on_launch
  map_public_ip_on_launch         = each.value.map_public_ip_on_launch
  outpost_arn                     = each.value.outpost_arn
  assign_ipv6_address_on_creation = each.value.assign_ipv6_address_on_creation
  tags                            = each.value.tags
}

###Routing
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name"    = "${var.project_name}-igw"
    "Project" = var.project_name
  }
}

resource "aws_route_table" "inet_rt" {
  vpc_id = aws_vpc.vpc.id
  route = [{
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
  }]
  tags = {
    "Name" = "${var.project_name}-inet_rt"
  }
}

resource "aws_route_table_association" "inet_rt_association" {
  subnet_id      = local.public_subnet_id
  route_table_id = aws_route_table.inet_rt.id
}

#### Security section

resource "aws_security_group" "public_sg" {
  #name        = "${var.project_name}-${each.value.name}"
  name        = "${var.project_name}-public_sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.vpc.id
  /*for_each    = { for ingress_rules in var.ingress_rules : ingress_rules.name => ingress_rules }
  ingress = [
    {
      description      = each.value.name
      from_port        = each.value.from_port
      to_port          = each.value.to_port
      protocol         = each.value.protocol
      cidr_blocks      = each.value.cidr_blocks
      security_groups  = each.value.security_groups
      ipv6_cidr_blocks = each.value.ipv6_cidr_blocks
      prefix_list_ids  = [each.value.prefix_list_ids]
      self             = each.value.self
    }
  ] */
}

resource "aws_security_group" "private_sg" {
  name = "${var.project_name}-private_sg"
  description = "Security group for private instances"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "security_group_rules" {
  for_each                 = { for security_group_rules in var.security_group_rules : security_group_rules.name => security_group_rules }
  security_group_id        = (each.value.security_group_type != "public" ? aws_security_group.private_sg.id : aws_security_group.public_sg.id)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  type                     = each.value.type
  cidr_blocks              = each.value.cidr_blocks
  description              = each.value.description
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  prefix_list_ids          = each.value.prefix_list_ids
  self                     = each.value.self
  source_security_group_id = (each.value.security_group_type != "public" ? aws_security_group.public_sg.id : null)
}

output "vpc_subnets" {
  value = { for subnet in aws_subnet.vpc_subnets : subnet.cidr_block => subnet.id }
}
output "name" {
  value = aws_subnet.vpc_subnets["192.168.0.0/24"].id

}

output "seca" {
  #value = {for name in var.ingress_rules : name.name => name }
  value = { for ingress_rules in var.ingress_rules : ingress_rules.name => ingress_rules }
}
