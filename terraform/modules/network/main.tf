resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc"
  }
}
resource "aws_subnet" "private_subnet_1_AZ" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_1_az_cidr
  availability_zone = var.availability_zone_1
  tags = {
    Name = "private_subnet_1_AZ"
  }
}
resource "aws_subnet" "private_subnet_2_AZ" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_2_az_cidr
  availability_zone = var.availability_zone_2
  tags = {
    Name = "private_subnet_2_AZ"
  }
}

resource "aws_subnet" "private_subnet_1_RDS" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_1_rds_cidr
  availability_zone = var.availability_zone_1
  tags = {
    Name = "private_subnet_1_RDS"
  }
}

resource "aws_subnet" "private_subnet_2_RDS" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_2_rds_cidr
  availability_zone = var.availability_zone_2
  tags = {
    Name = "private_subnet_2_RDS"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "nat_eip1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "nat_gw"
  }
}

resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.public_subnet_2.id
  tags = {
    Name = "nat_gw"
  }
}

resource "aws_route_table" "private_route_table1" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1.id
  }
}

resource "aws_route_table" "private_route_table2" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw2.id
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_route_table_association" "private_compute_az1" {
  subnet_id      = aws_subnet.private_subnet_1_AZ.id
  route_table_id = aws_route_table.private_route_table1.id
}

resource "aws_route_table_association" "private_rds_az1" {
  subnet_id      = aws_subnet.private_subnet_1_RDS.id
  route_table_id = aws_route_table.private_route_table1.id
}
resource "aws_route_table_association" "private_compute_az2" {
  subnet_id      = aws_subnet.private_subnet_2_AZ.id
  route_table_id = aws_route_table.private_route_table2.id
}

resource "aws_route_table_association" "private_rds_az2" {
  subnet_id      = aws_subnet.private_subnet_2_RDS.id
  route_table_id = aws_route_table.private_route_table2.id
}