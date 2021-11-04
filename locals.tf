locals {
  public_subnet_id = aws_subnet.vpc_subnets["192.168.0.0/24"].id ###Is it ok?
}