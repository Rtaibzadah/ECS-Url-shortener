resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-vpc" })
}

resource "aws_subnet" "private_subnet" {
  for_each          = var.private_subnet_cidr
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-${each.key}-private-subnet" })
}

resource "aws_subnet" "public_subnet" {
  for_each          = var.public_subnet_cidr
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-${each.key}-public-subnet" })
}

#route table - public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-public-rt" })
}

resource "aws_route_table_association" "public_rt_association" {
  for_each       = var.public_subnet_cidr
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

#route table - private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-private-rt" })
}

resource "aws_route_table_association" "private_rt_association" {
  for_each       = var.private_subnet_cidr
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-igw" })
}

#RDB subnet group
resource "aws_db_subnet_group" "postgres" {
  name       = "postgres-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_subnet : subnet.id]

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-postgres-subnet-group" })
}

#elasticache
resource "aws_elasticache_subnet_group" "elasticache" {
  name       = "elasticache-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_subnet : subnet.id]

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-elasticache-subnet-group" })
}

#VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rt.id]

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-s3-endpoint" })
}

#VPC Endpoints (interface)
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  security_group_ids  = [var.vpc_endpoints_sg]
  private_dns_enabled = true

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-ecr-dkr-endpoint" })
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  security_group_ids  = [var.vpc_endpoints_sg]
  private_dns_enabled = true

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-logs-endpoint" })
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  security_group_ids  = [var.vpc_endpoints_sg]
  private_dns_enabled = true

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-sqs-endpoint" })
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private_subnet : subnet.id]
  security_group_ids  = [var.vpc_endpoints_sg]
  private_dns_enabled = true

  tags = merge(var.common_tags, { Name = "${var.common_tags.Project}-secretsmanager-endpoint" })
}
