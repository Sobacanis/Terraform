data "aws_availability_zones" "az-available" {
  state = "available"
}

####Networking section

###Switching
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

resource "aws_subnet" "vpc_subnets" {
  for_each                        = { for subnets in local.subnets_config : subnets.cidr_block => subnets }
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
  route  = [local.inet_route]
  tags = {
    "Name" = "${var.project_name}-inet_rt"
  }
}

resource "aws_route_table_association" "inet_rt_association" {
  subnet_id      = local.public_subnet_id
  route_table_id = aws_route_table.inet_rt.id
}

#### Security section 


resource "aws_security_group" "security_groups" {
  for_each    = { for security_groups in var.security_groups : security_groups.name => security_groups }
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "security_group_rules" {
  for_each                 = { for security_group_rules in var.security_group_rules : security_group_rules.name => security_group_rules }
  security_group_id        = each.value.security_group_type == "public" ? aws_security_group.security_groups["public_sg"].id : aws_security_group.security_groups["private_sg"].id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  type                     = each.value.type
  cidr_blocks              = each.value.cidr_blocks
  description              = each.value.description
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  prefix_list_ids          = each.value.prefix_list_ids
  self                     = each.value.self
  source_security_group_id = each.value.security_group_type != "public" ? aws_security_group.security_groups["private_sg"].id : null
}

#### Database section

resource "aws_db_parameter_group" "db_parameter_groups" {
  for_each    = { for parameter_grpoup in var.db_parmater_groups : parameter_grpoup.name => parameter_grpoup }
  name        = each.value.name
  family      = each.value.family
  description = each.value.description
  dynamic "parameter" {
    for_each = each.value.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
}