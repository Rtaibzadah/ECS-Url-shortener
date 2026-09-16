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
