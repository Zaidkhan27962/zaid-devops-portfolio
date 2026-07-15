data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
resource "aws_vpc" "portfolio_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "portfolio-vpc"
  }
}
resource "aws_subnet" "public_subnet" {

  vpc_id                  = aws_vpc.portfolio_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "portfolio-public-subnet"
  }
}
resource "aws_internet_gateway" "portfolio_igw" {

  vpc_id = aws_vpc.portfolio_vpc.id

  tags = {
    Name = "portfolio-igw"
  }

}

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.portfolio_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.portfolio_igw.id
  }

  tags = {
    Name = "portfolio-public-route-table"
  }

}
resource "aws_route_table_association" "public_assoc" {

  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id

}
resource "aws_security_group" "portfolio_sg" {

  name        = "portfolio-security-group"
  description = "Security Group for Portfolio"
  vpc_id      = aws_vpc.portfolio_vpc.id

  ingress {
    description = "SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"

    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "portfolio-security-group"
  }

}
resource "aws_key_pair" "portfolio_key" {
  key_name   = "portfolio-key"
  public_key = file("/home/zaid/.ssh/id_ed25519.pub")
}
resource "aws_instance" "portfolio_ec2" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.portfolio_sg.id]

  key_name = aws_key_pair.portfolio_key.key_name

  tags = {
    Name = "portfolio-ec2"
  }
}
resource "aws_eip" "portfolio_eip" {
  domain = "vpc"

  tags = {
    Name = "portfolio-eip"
  }
}

resource "aws_eip_association" "portfolio_eip_assoc" {
  instance_id   = aws_instance.portfolio_ec2.id
  allocation_id = aws_eip.portfolio_eip.id
}