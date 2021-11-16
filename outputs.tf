output "vpc_subnets" {
  value = { for subnet in aws_subnet.vpc_subnets : subnet.cidr_block => subnet.id }
}

output "chck" {
  value = aws_security_group.security_groups["private_sg"].id
}