#VPC Creation
resource "aws_vpc" "zhenxing-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
      Name = "zhenxing-vpc"
    }
}

#SUBNET CREATION

resource "aws_subnet" "zhenxing-vpc-pb-1a" {
    vpc_id = aws_vpc.zhenxing-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-2a"
        map_public_ip_on_launch = true
    tags = {
      Name = "zhenxing-vpc-pb-1a"
    }
}

resource "aws_subnet" "zhenxing-vpc-pvt-1a" {
    vpc_id = aws_vpc.zhenxing-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2a"
    tags ={
        Name = "zhenxing-vpc-pvt-1a"
    }
}

resource "aws_subnet" "zhenxing-vpc-pb-1b" {
    vpc_id = aws_vpc.zhenxing-vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-2b"
    map_public_ip_on_launch = true

    tags ={
        Name = "zhenxing-vpc-pb-1b"
    }
}


resource "aws_subnet" "zhenxing-vpc-pvt-1b" {
    vpc_id = aws_vpc.zhenxing-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-2b"
    tags ={
        Name = "zhenxing-vpc-pvt-1b"
    }
}

#INTERNET_GATEWAY => Only for Public Subnets

resource "aws_internet_gateway" "zhenxing-vpc-igw" {
  vpc_id = aws_vpc.zhenxing-vpc.id
  tags ={
    Name = "zhenxing-vpc-igw"
  }
}

#NAT_GATEWAY => Only for Private subnets 

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "zhenxing-vpc-nat-gw" {
    allocation_id = aws_eip.nat_gateway.id
    subnet_id     = aws_subnet.zhenxing-vpc-pb-1a.id

    tags = {
        Name = "zhenxing-vpc-nat-gw"
    }
    depends_on = [aws_internet_gateway.zhenxing-vpc-igw]
}

#ROUTE-TABLE CREATION

resource "aws_route_table" "zhenxing-vpc-rt-pb" {
    vpc_id = aws_vpc.zhenxing-vpc.id
    route{
        cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.zhenxing-vpc-igw.id
    }
    tags ={
        Name = "zhenxing-vpc-rt-pb"
    }
}


resource "aws_route_table" "zhenxing-vpc-rt-pvt" {
  vpc_id = aws_vpc.zhenxing-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.zhenxing-vpc-nat-gw.id
  }
  tags = {
    Name = "zhenxing-vpc-rt-pvt"
  }
}


#ROUTE-TABLE ASSOCIATIONG
resource "aws_route_table_association" "pb-1a" {
    subnet_id      = aws_subnet.zhenxing-vpc-pb-1a.id
    route_table_id = aws_route_table.zhenxing-vpc-rt-pb.id
}

resource "aws_route_table_association" "pb-1b" {
    subnet_id      = aws_subnet.zhenxing-vpc-pb-1b.id
    route_table_id = aws_route_table.zhenxing-vpc-rt-pb.id
}

resource "aws_route_table_association" "pvt-1a" {
    subnet_id      = aws_subnet.zhenxing-vpc-pvt-1a.id
    route_table_id = aws_route_table.zhenxing-vpc-rt-pvt.id
}

resource "aws_route_table_association" "pvt-1b" {
    subnet_id      = aws_subnet.zhenxing-vpc-pvt-1b.id
    route_table_id = aws_route_table.zhenxing-vpc-rt-pvt.id
}