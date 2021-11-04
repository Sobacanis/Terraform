subnets_config = [{
  name       = "public"
  cidr_block = "192.168.0.0/24"
  #map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
  },
  {
    name                    = "private-01"
    cidr_block              = "192.168.1.0/24"
    map_public_ip_on_launch = false
    tags = {
      Name = "private_subnet-01"
    }
  },
  {
    name                    = "private-02"
    cidr_block              = "192.168.2.0/24"
    map_public_ip_on_launch = false
    tags = {
      Name = "private_subnet-02"
    }
  }
]

ingress_rules = [
  {
    name                = "http"
    security_group_type = "public"
    description         = "Access to http from everywhere"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
    prefix_list_ids     = ""
  },
  {
    name                = "https"
    security_group_type = "public"
    description         = "Access to https from everywhere"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
    prefix_list_ids     = ""
  },
  {
    name                = "client_ssh"
    security_group_type = "public"
    description         = "Access to ssh from client's IP ranges"
    cidr_blocks         = ["176.106.217.78/32"]
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    prefix_list_ids     = ""
  },
  {
    name                = "mysql"
    security_group_type = "private"
    description         = "Access to MySql from public subnet"
    from_port           = 3306
    to_port             = 3306
    protocol            = "tcp"
    security_groups     = [""]
    prefix_list_ids     = ""
  }
]

security_group_rules = [
  {
    name                = "http"
    security_group_type = "public"
    type                = "ingress"
    description         = "Access to http from everywhere"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
  },
  {
    name                = "https"
    security_group_type = "public"
    type                = "ingress"
    description         = "Access to https from everywhere"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
  },
  {
    name                = "ssh"
    security_group_type = "public"
    type                = "ingress"
    description         = "Access to ssh from clients IP ranges"
    cidr_blocks         = ["176.106.217.78/32"]
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
  },
  {
    name                = "MySql"
    security_group_type = "private"
    type                = "ingress"
    description         = "Access to MySql from public subnet"
    from_port           = 3306
    to_port             = 3306
    protocol            = "tcp"
  },
  {
    name                = "all_public"
    security_group_type = "public"
    type                = "egress"
    description         = "Access to http from everywhere"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 0
    to_port             = 65535
    protocol            = "all"
  },
  {
    name                = "all_private"
    security_group_type = "public"
    type                = "ingress"
    description         = "Access to http from everywhere"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 0
    to_port             = 65535
    protocol            = "all"
  },
]