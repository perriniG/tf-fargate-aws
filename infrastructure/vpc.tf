provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}
########## VPC ##########
resource "aws_vpc" "production_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "Production-VPC"
  }
}

########## Public-subnets ##########

resource "aws_subnet" "public_subnet_1" {
  cidr_block        = var.public_subnet_1_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "${var.region}a"

  tags = {
    Name = "Public-Subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  cidr_block        = var.public_subnet_2_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "${var.region}b"

  tags = {
    Name = "Public-Subnet-2"
  }
}
resource "aws_subnet" "public_subnet_3" {
  cidr_block        = var.public_subnet_3_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "${var.region}c"

  tags = {
    Name = "Public-Subnet-3"
  }
}

########## Private-subnets ##########

resource "aws_subnet" "private_subnet_1" {
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "${var.region}a"

  tags = {
    Name = "Private-Subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "${var.region}b"

  tags = {
    Name = "Private-Subnet-2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  cidr_block        = var.private_subnet_3_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "${var.region}c"

  tags = {
    Name = "Private-Subnet-3"
  }
}
########## Route Table ##########
########## Public ##########

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "Public route table"
  }

}
########## Private ##########

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "Private route table"
  }

}
########## Association ##########
########## Public ##############
resource "aws_route_table_association" "public_subnet_1_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_1.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_2.id
}

resource "aws_route_table_association" "public_subnet_3_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_3.id
}

########## Private ##########

resource "aws_route_table_association" "private_subnet_1_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_1.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_2.id
}

resource "aws_route_table_association" "private_subnet_3_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_3.id
}

########## Elastic Ip ##########

resource "aws_eip" "elastic_ip_for_nat_gw" {
  vpc                       = "true"
  associate_with_private_ip = "10.0.0.5"

  tags = {
    Name = "Production-EIP"
  }
}
######### NAT GW ##############

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.elastic_ip_for_nat_gw.id
  subnet_id     = aws_subnet.private_subnet_1.id

  tags = {
    Name = "Production-NAT-GW"
  }

  depends_on = [ aws_eip.elastic_ip_for_nat_gw ]
}

resource "aws_route" "nat_gw_route" {
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  destination_cidr_block = "0.0.0.0/0"
}

######### Internet Gateway #########
resource "aws_internet_gateway" "production_igw" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "Production_IG"
  }
}

resource "aws_route" "public_internet_gw_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.production_igw.id
  destination_cidr_block = "0.0.0.0/0"
}