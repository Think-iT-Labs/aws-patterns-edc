# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-vpc"
    Tier = "vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
    Tier = "igw"
  }
}

# Private Subnets
resource "aws_subnet" "private_zone" {
  for_each = {
    for idx, az in var.eks_availability_zones : az => {
      subnet_cidr_block = var.subnet_cidr_blocks[idx]
      availability_zone = az
    }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.subnet_cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    "Name"                                  = "${var.vpc_name}-private-${each.value.availability_zone}"
    "kubernetes.io/role/internal-elb"       = "1"
    "kubernetes.io/cluster/${var.eks_name}" = "owned"
    Tier                                    = "private-subnet"
  }
}

# Public Subnets
resource "aws_subnet" "public_zone" {
  for_each = {
    for idx, az in var.eks_availability_zones : az => {
      subnet_cidr_block = var.subnet_cidr_blocks[idx + length(var.eks_availability_zones)]
      availability_zone = az
    }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.subnet_cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    "Name"                                  = "${var.vpc_name}-public-${each.value.availability_zone}"
    "kubernetes.io/role/elb"                = "1"
    "kubernetes.io/cluster/${var.eks_name}" = "owned"
    Tier                                    = "public-subnet"
  }
}

# Static Elastic IP for NAT Gateway
resource "aws_eip" "eip_nat" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Tier = "elastic-ip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public_zone[var.eks_availability_zones[1]].id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.vpc_name}-natgw"
  }
}

# Route Tables for Private Subnets
resource "aws_route_table" "rt_private_zone" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.vpc_name}-private-route"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "rt_public_zone" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-route"
  }
}

# Route Table Associations for Private Subnets
resource "aws_route_table_association" "rt_private_zone" {
  for_each = {
    for idx, az in var.eks_availability_zones : az => {
      subnet_id = aws_subnet.private_zone[az].id
    }
  }
  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.rt_private_zone.id
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "rt_public_zone" {
  for_each = {
    for idx, az in var.eks_availability_zones : az => {
      subnet_id = aws_subnet.public_zone[az].id
    }
  }
  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.rt_public_zone.id
}
