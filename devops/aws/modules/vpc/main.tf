# VPC

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-${var.environment}"
    Env  = var.environment
  }
}

# SUBNETS

variable "public_subnets_config" {
  type = map(object({
    name   = string
    az     = string
    public = bool
    cidr   = string
  }))
}

variable "private_subnets_config" {
  type = map(object({
    name   = string
    az     = string
    public = bool
    cidr   = string
  }))
}

resource "aws_subnet" "subnet_public" {
  for_each                = var.public_subnets_config
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-${each.value.name}"
    Env  = var.environment
  }
}

resource "aws_subnet" "subnet_private" {
  for_each          = var.private_subnets_config
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "${var.environment}-${each.value.name}"
    Env  = var.environment
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw-${var.environment}"
    Env  = var.environment
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "eip-nat-${var.environment}"
    Env  = var.environment
  }
  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway in first public subnet
resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.subnet_public[keys(aws_subnet.subnet_public)[0]].id
  allocation_id = aws_eip.nat.id
  tags = {
    Name = "ngw-${var.environment}"
    Env  = var.environment
  }
  depends_on = [aws_internet_gateway.igw]
}


# PUBLIC ROUTE TABLE
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rtb-public-${var.environment}"
    Env  = var.environment
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.subnet_public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# PRIVATE ROUTE TABLE
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "rtb-private-${var.environment}"
    Env  = var.environment
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.subnet_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
