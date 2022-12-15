provider "aws" {
  version = "~>3.0"
  region = "us-east-1"
}
resource "aws_vpc" "vpc1" {
  cidr_block = "100.0.0.0/24"
  tags = {
    Name = "requester"
  }
}
resource "aws_vpc" "vpc2" {
  cidr_block = "100.0.1.0/24"
  tags = {
    Name = "accepter"
  }
}
resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id = aws_vpc.vpc2.id
  vpc_id      = aws_vpc.vpc1.id
  auto_accept = true
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id
}
resource "aws_subnet" "sub1_for_vpc1" {
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.vpc1.id
  availability_zone = "us-east-1a"
  cidr_block = "100.0.0.0/24"
  tags = {
    Name = "Requester_Subnet"
  }
}
resource "aws_subnet" "sub1_for_vpc2" {
  vpc_id = aws_vpc.vpc2.id
  availability_zone = "us-east-1a"
  cidr_block = "100.0.1.0/24"
  tags = {
    Name = "Accespeter"
  }
}
resource "aws_security_group" "sg1" {
  name = "securityGroupforTerraform"
  description = "sg"
  vpc_id = aws_vpc.vpc1.id
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "sg2" {
  name = "securityGroupforTerraform"
  description = "sg"
  vpc_id = aws_vpc.vpc2.id
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "ec2-1-for-requester" {
  ami = "ami-0cff7528ff583bf9a"
  subnet_id = aws_subnet.sub1_for_vpc1.id
  instance_type = "t2.micro"
    security_groups = [aws_security_group.sg1.id]
  tags = {
    Name = "requesterEC2"
  }
}
resource "aws_instance" "ec2-1-for-accepter" {
  ami = "ami-0cff7528ff583bf9a"
  subnet_id = aws_subnet.sub1_for_vpc2.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.sg2.id]
  tags = {
    Name = "accepterEC2"
  }
}
resource"aws_route_table" "r1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "vpc-1-rt"
  }
}
resource "aws_route_table" "r2" {
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "vpc-2-rt"
  }
}
resource "aws_route_table_association" "r1-asso" {
  route_table_id = aws_route_table.r1.id
  subnet_id = aws_subnet.sub1_for_vpc1.id
}
resource "aws_route_table_association" "r2-asso" {
  route_table_id = aws_route_table.r2.id
  subnet_id = aws_subnet.sub1_for_vpc2.id
}
resource "aws_route" "routeFor-1" {
  route_table_id = aws_route_table.r1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_route" "routeFor-1" {
  route_table_id = aws_route_table.r1.id
  destination_cidr_block = "100.0.1.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}
resource "aws_route" "route-2" {
  route_table_id = aws_route_table.r2.id
  destination_cidr_block = "100.0.0.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}
