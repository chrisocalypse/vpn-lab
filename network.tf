/*
resource "aws_network_interface_sg_attachment" "publicattachment" {
  depends_on           = [aws_network_interface.eth0]
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.eth0.id
}

*/

// tailscale router instance
resource "aws_instance" "tailscale_router" {
  ami           = "ami-0b9932f4918a00c4f"
  instance_type = "t2.micro"
  key_name = "newkey"
  #subnet_id = aws_subnet.publicsubnetaz1.id
  #source_dest_check = false
  #associate_public_ip_address = "true"
  #security_groups = [aws_security_group.public_allow.id]
  tags = {
    Name = "tailscale_router"
  }
  network_interface {
    network_interface_id = aws_network_interface.eth0-router.id
    device_index         = 0
    
  }
}

resource "aws_network_interface" "eth0-router" {
  description = "tailscale_router interface"
  subnet_id   = aws_subnet.publicsubnetaz1.id
  security_groups = [aws_security_group.public_allow.id]
  source_dest_check = false
}

resource "aws_instance" "webserver" {
  ami           = "ami-0b9932f4918a00c4f"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.privatesubnetaz1.id
  associate_public_ip_address = "false"
  security_groups = [aws_security_group.allow_all.id]
  key_name = "newkey"
  tags = {
    Name = "webserver"
  }
}


// Creating Internet Gateway
resource "aws_internet_gateway" "vpn-igw" {
  vpc_id = aws_vpc.vpntest-vpc.id
  tags = {
    Name = "vpntest-igw"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.ngwPublicIP.id
  subnet_id     = aws_subnet.ngwsubnetaz1.id
  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.vpn-igw]
}

// Route Table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpntest-vpc.id

  tags = {
    Name = "vpn-public-rt"
  }
}

resource "aws_route_table" "vpn-rt" {
  vpc_id = aws_vpc.vpntest-vpc.id

  tags = {
    Name = "vpn-private-rt"
  }
}

resource "aws_route" "externalroute" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpn-igw.id
}

resource "aws_route" "internalroute" {
  depends_on             = [aws_instance.tailscale_router]
  route_table_id         = aws_route_table.vpn-rt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.eth0-router.id

}

resource "aws_route_table_association" "public1associate" {
  subnet_id      = aws_subnet.publicsubnetaz1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "internalassociate" {
  subnet_id      = aws_subnet.privatesubnetaz1.id
  route_table_id = aws_route_table.vpn-rt.id
}


resource "aws_eip" "RouterPublicIP" {
  depends_on        = [aws_instance.tailscale_router]
  domain            = "vpc"
  network_interface = aws_network_interface.eth0-router.id
}


resource "aws_eip" "ngwPublicIP" {
  domain            = "vpc"
}

// Security Group

resource "aws_security_group" "public_allow" {
  name        = "Public Allow"
  description = "Public Allow traffic"
  vpc_id      = aws_vpc.vpntest-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Public Allow"
  }
  }

resource "aws_security_group" "allow_all" {
  name        = "Allow All"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.vpntest-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public Allow"
  }
}
