// AWS VPC 
resource "aws_vpc" "vpntest-vpc" {
  cidr_block           = var.vpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "tailscale vpn test"
  }
}

resource "aws_subnet" "publicsubnetaz1" {
  vpc_id            = aws_vpc.vpntest-vpc.id
  cidr_block        = var.publiccidraz1
  availability_zone = var.az1
  tags = {
    Name = "public subnet az1"
  }
}

resource "aws_subnet" "privatesubnetaz1" {
  vpc_id            = aws_vpc.vpntest-vpc.id
  cidr_block        = var.privatecidraz1
  availability_zone = var.az1
  tags = {
    Name = "private subnet az1"
  }
}
resource "aws_subnet" "ngwsubnetaz1" {
  vpc_id            = aws_vpc.vpntest-vpc.id
  cidr_block        = var.natcidraz1
  availability_zone = var.az1
  tags = {
    Name = "ngw subnet az1"
  }
}
