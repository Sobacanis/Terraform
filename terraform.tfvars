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

security_groups = [
  {
    name        = "public_sg"
    description = "Security group for public instances"
  },
  {
    name        = "private_sg"
    description = "Security group for private instances"
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
    description         = "Egress to everywhere"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 0
    to_port             = 65535
    protocol            = "all"
  },
  {
    name                = "all_private"
    security_group_type = "private"
    type                = "egress"
    description         = "Egress to everywhere"
    from_port           = 0
    to_port             = 65535
    protocol            = "all"
  },
]

db_parmater_groups = [{
  family      = "mysql8.0"
  name        = "mysql-8-01"
  description = "Eight-zero-one"
  parameters = [{
    name  = "autocommit"
    value = "1"
    },
    {
      name  = "binlog_checksum"
      value = "NONE"
    },
    {
      name  = "innodb_adaptive_flushing"
      value = "0"
    },
    {
      name         = "skip_show_database"
      value        = "0"
      apply_method = "pending-reboot"
  }]
  },
  {
    family      = "mysql8.0"
    name        = "mysql-8-02"
    description = "Eight-zero-two"
    parameters = [{
      name  = "autocommit"
      value = "1"
    }]
  },
  {
    family      = "mysql5.7"
    name        = "mysql-57-01"
    description = "fiveseven-one"
    parameters = [{
      name  = "autocommit"
      value = "0"
      },
      {
        name         = "query_cache_type"
        value        = "2"
        apply_method = "pending-reboot"
      },
      {
        name  = "old_passwords"
        value = "0"
      },
      {
        name  = "innodb_stats_on_metadata"
        value = "0"
    }]
  },
  {
    family      = "mysql5.6"
    name        = "mysql-56-01"
    description = "five-six-one"
    parameters = [{
      name  = "innodb_compression_level"
      value = "7"
    }]
  }
]