#########Create VPC#############
resource "aws_vpc" "myvpc" {
  provider = aws.deployer
  cidr_block = var.cidr

  tags = {
    Name = "myvpc"
  }
}

###########Create Internet-Gateway#########
resource "aws_internet_gateway" "my-igw" {
  provider = aws.deployer
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my-igw"
  }
}

########Create Public-Subnet##########
resource "aws_subnet" "pub-subnet" {
  provider = aws.deployer
  cidr_block        = var.public_subnets[0]
  availability_zone = var.availability_zones[0]
  vpc_id            = aws_vpc.myvpc.id

  tags = {
    Name = "pub-subnet"
  }
}

########Create private--Subnet##########
resource "aws_subnet" "pvt-subnet" {
  provider = aws.deployer
  cidr_block        = var.private_subnets[0]  # Use index [0] instead of [1]
  availability_zone = var.availability_zones[1]
  vpc_id            = aws_vpc.myvpc.id

  tags = {
    Name = "pvt-subnet"
  }
}

##############create elastic ip###########
resource "aws_eip" "elastic-ip" {
  provider = aws.deployer
  domain = "vpc"
  depends_on  = [aws_internet_gateway.my-igw]
}

############Create NAT Gateway#########

resource "aws_nat_gateway" "ngw" {
  provider = aws.deployer
  allocation_id = aws_eip.elastic-ip.id
  subnet_id     = aws_subnet.pub-subnet.id
  depends_on    = [aws_eip.elastic-ip]

  tags = {
    Name = "nat-gateway"
  }
}

###############Create Route Table##########
###############Public-route##############
resource "aws_route_table" "pub-rt" {
  provider = aws.deployer
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }


  tags = {
    Name = "pub-rt"
  }
}

###############Private-route##############
resource "aws_route_table" "pvt-rt" {
  provider = aws.deployer
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }


  tags = {
    Name = "pvt-rt"
  }
}

#################Subnet-Association###########
#################Public-Subnet Accociation############
resource "aws_route_table_association" "a" {
  provider = aws.deployer
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.pub-rt.id
}

#################Private-Subnet Accociation############

resource "aws_route_table_association" "b" {
  provider = aws.deployer
  subnet_id      = aws_subnet.pvt-subnet.id
  route_table_id = aws_route_table.pvt-rt.id
}


##################create Security Group for nginx##############
resource "aws_security_group" "allow22and80port" {
  provider = aws.deployer
 name        = "nginx-web-server-sg-tf"
 description = "Allow port 22 and port 80"
 vpc_id      = aws_vpc.myvpc.id

ingress {
   description = "ssh ingress"
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

ingress {
   description = "http ingress"
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
 tags = {
    Name = "nginx-sg"
  }
}

##############creating ec2 instances-nginx##############

resource "aws_instance" "nginx-instance" {
  provider = aws.deployer
  ami           = var.ami_id
  count         = var.instance_count
  instance_type = var.instance_type
  subnet_id      = aws_subnet.pub-subnet.id
  availability_zone = var.availability_zones[0]
  associate_public_ip_address = true  # Enable public IP assignment
  vpc_security_group_ids = [aws_security_group.allow22and80port.id]
  tags = {
    Name = "nginx-instance"
  }
  user_data = <<-EOF
    #!/bin/bash
    adduser ansible --disabled-password --gecos ""
    echo "newuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/newuser
  EOF
}
############creating frontend sg#############
##### Allow traffic from Nginx security group to Frontend security group########

resource "aws_security_group" "frontend-sg" {
  provider = aws.deployer
  name        = "frontend-security-group-tf"
  description = "Allow port 5000 and traffic from Nginx SG"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "Allow traffic from Nginx SG"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    security_groups = [aws_security_group.allow22and80port.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-sg"
  }
}

##############creating ec2 instances-frontend##############

resource "aws_instance" "frontend-instance" {
  provider = aws.deployer
  ami           = var.ami_id
  count         = var.instance_count
  instance_type = var.instance_type
  subnet_id      = aws_subnet.pvt-subnet.id
  availability_zone = var.availability_zones[1]
  vpc_security_group_ids = [aws_security_group.frontend-sg.id]
  tags = {
    Name = "frontend-instance"
  }
  user_data = <<-EOF
    #!/bin/bash
    adduser ansible --disabled-password --gecos ""
    echo "newuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/newuser
  EOF
}
############creating backend sg#############
##### Allow traffic from Frontend security group to Backend security group########

resource "aws_security_group" "backend-sg" {
  provider = aws.deployer
  name        = "backend-security-group-tf"
  description = "Allow port 8000 and traffic from Frontend SG"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "Allow traffic from Frontend SG"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [aws_security_group.frontend-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}
##############creating ec2 instances-backend##############

resource "aws_instance" "backend-instance" {
  provider = aws.deployer
  ami           = var.ami_id
  count         = var.instance_count
  instance_type = var.instance_type
  subnet_id      = aws_subnet.pvt-subnet.id
  availability_zone = var.availability_zones[1]
  vpc_security_group_ids = [aws_security_group.backend-sg.id]
  tags = {
    Name = "backend-instance"
  }
  user_data = <<-EOF
    #!/bin/bash
    adduser ansible --disabled-password --gecos ""
    echo "newuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/newuser
  EOF
}

############creating database-mysql sg#############
##### you can allow backend security group in mysql security group########

resource "aws_security_group" "mysql-sg" {
  provider = aws.deployer
  name        = "mysql-security-group-tf"
  description = "Allow port 3306 and traffic from Backend SG"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "Allow traffic from Backend SG"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.backend-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql-sg"
  }
}

##############creating ec2 instances-mysql##############

resource "aws_instance" "mysql-instance" {
  provider = aws.deployer
  ami           = var.ami_id
  count         = var.instance_count
  instance_type = var.instance_type
  subnet_id      = aws_subnet.pvt-subnet.id
  availability_zone = var.availability_zones[1]
  vpc_security_group_ids = [aws_security_group.mysql-sg.id]
  tags = {
    Name = "mysql-instance"
  }
  user_data = <<-EOF
    #!/bin/bash
    adduser ansible --disabled-password --gecos ""
    echo "newuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/newuser
  EOF
}


