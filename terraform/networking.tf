resource "aws_vpc" "vpc" {
  cidr_block                       = "10.0.0.0/16"
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags                             = { Name = var.resource_names.vpc }
}

resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.vpc.id
  tags       = { Name = var.resource_names.igw }
  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false
  tags                    = { Name = var.resource_names.subnets.private.a }
  depends_on              = [aws_vpc.vpc]
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false
  tags                    = { Name = var.resource_names.subnets.private.b }
  depends_on              = [aws_vpc.vpc]
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = var.resource_names.subnets.public.a }
  depends_on              = [aws_vpc.vpc]
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = var.resource_names.subnets.public.b }
  depends_on              = [aws_vpc.vpc]
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_a.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id     = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }
  tags       = { Name = var.resource_names.route_tables.private }
  depends_on = [aws_vpc.vpc]
}

resource "aws_route_table_association" "private_route_table_associations_1" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
  depends_on     = [aws_subnet.private_subnet_a, aws_route_table.private_route_table]
}

resource "aws_route_table_association" "private_route_table_associations_2" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
  depends_on     = [aws_subnet.private_subnet_b, aws_route_table.private_route_table]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags       = { Name = var.resource_names.route_tables.public }
  depends_on = [aws_vpc.vpc]
}

resource "aws_route_table_association" "public_route_table_associations_1" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
  depends_on     = [aws_subnet.public_subnet_a, aws_route_table.public_route_table]
}

resource "aws_route_table_association" "public_route_table_associations_2" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
  depends_on     = [aws_subnet.public_subnet_b, aws_route_table.public_route_table]
}

resource "aws_security_group" "security_group_ec2" {
  name       = var.resource_names.security_groups.ec2
  vpc_id     = aws_vpc.vpc.id
  tags       = { Name = var.resource_names.security_groups.ec2 }
  depends_on = [aws_vpc.vpc]
}

resource "aws_security_group" "security_group_alb" {
  name       = var.resource_names.security_groups.alb
  vpc_id     = aws_vpc.vpc.id
  tags       = { Name = var.resource_names.security_groups.alb }
  depends_on = [aws_vpc.vpc]
}

resource "aws_security_group_rule" "security_group_rule_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Internet access"
  security_group_id = aws_security_group.security_group_ec2.id
  depends_on        = [aws_security_group.security_group_ec2]
}

resource "aws_security_group_rule" "security_group_rule_2" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.security_group_alb.id
  description              = "Webapp balancer access"
  security_group_id        = aws_security_group.security_group_ec2.id
  depends_on               = [aws_security_group.security_group_ec2, aws_security_group.security_group_alb]
}

resource "aws_security_group_rule" "security_group_rule_3" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Webapp public access"
  security_group_id = aws_security_group.security_group_alb.id
  depends_on        = [aws_security_group.security_group_ec2, aws_security_group.security_group_alb]
}

resource "aws_security_group_rule" "security_group_rule_4" {
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.security_group_ec2.id
  description              = "Webapp instances access"
  security_group_id        = aws_security_group.security_group_alb.id
  depends_on               = [aws_security_group.security_group_ec2, aws_security_group.security_group_alb]
}