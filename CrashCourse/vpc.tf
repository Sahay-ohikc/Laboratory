data "aws_availability_zones" "azs" {
}

resource "aws_vpc" "vpc" {
  cidr_block = "172.40.0.0/16"

  tags = {
    Name = "eks-crash-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "eks-crash-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "eks-crash-public"
  }
}

resource "aws_route_table_association" "public1" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public1.id
}

resource "aws_route_table_association" "public2" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public2.id
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.40.1.0/24"
  availability_zone = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-crash-public-1"
    "kubernetes.io/cluster/eks-crash" = "shared"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.40.2.0/24"
  availability_zone = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-crash-public-2"
    "kubernetes.io/cluster/eks-crash" = "shared"
  }
}
