terraform {
}

# Configuration options
provider "aws" {
  region     = var.region
}

#Create vpc
resource "aws_vpc" "e-learning-vpcnew" {
  cidr_block           = var.e-learning-vpcnew_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "${var.e-learning-vpcnew_cidr}"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


#Create x2 Public Subnet
resource "aws_subnet" "e-learning-pub-sub1new" {
  cidr_block        = var.e-learning-pub-sub1new_cidr
  vpc_id            = aws_vpc.e-learning-vpcnew.id
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    "Name" = "${var.e-learning-pub-sub1new_cidr}"
  }
}

resource "aws_subnet" "e-learning-pub-sub2new" {
  cidr_block        = var.e-learning-pub-sub2new_cidr
  vpc_id            = aws_vpc.e-learning-vpcnew.id
  availability_zone = data.aws_availability_zones.available_zones.names[1]

  tags = {
    "Name" = "${var.e-learning-pub-sub2new_cidr}"
  }
}


#Create x2 Private Subnet
resource "aws_subnet" "e-learning-priv-sub1new" {
  cidr_block        = var.e-learning-priv-sub1new_cidr
  vpc_id            = aws_vpc.e-learning-vpcnew.id
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    "Name" = "${var.e-learning-priv-sub1new_cidr}"
  }
}


resource "aws_subnet" "e-learning-priv-sub2new" {
  cidr_block        = var.e-learning-priv-sub2new_cidr
  vpc_id            = aws_vpc.e-learning-vpcnew.id
  availability_zone = data.aws_availability_zones.available_zones.names[1]

  tags = {
    "Name" = "${var.e-learning-priv-sub2new_cidr}"
  }
}


# Create a public route table 
resource "aws_route_table" "e-learning-pub-rtb1" {
  vpc_id = aws_vpc.e-learning-vpcnew.id
}


# Create a private route table 
resource "aws_route_table" "e-learning-priv-rtb1" {
  vpc_id = aws_vpc.e-learning-vpcnew.id
}


#Create Public Route Table and Subnet Association
resource "aws_route_table_association" "e-learning-pub-sub1-assoc" {
  route_table_id = aws_route_table.e-learning-pub-rtb1.id
  subnet_id      = aws_subnet.e-learning-pub-sub1new.id
}

resource "aws_route_table_association" "e-learning-pub-sub2-assoc" {
  route_table_id = aws_route_table.e-learning-pub-rtb1.id
  subnet_id      = aws_subnet.e-learning-pub-sub2new.id
}


#Create Private Route Table and Subnet Association
resource "aws_route_table_association" "e-learning-priv-sub1-assoc" {
  route_table_id = aws_route_table.e-learning-priv-rtb1.id
  subnet_id      = aws_subnet.e-learning-priv-sub1new.id
}

resource "aws_route_table_association" "e-learning-priv-sub2-assoc" {
  route_table_id = aws_route_table.e-learning-priv-rtb1.id
  subnet_id      = aws_subnet.e-learning-priv-sub2new.id
}


# Create internet gateway
resource "aws_internet_gateway" "e-learning-igw" {
  vpc_id = aws_vpc.e-learning-vpcnew.id

  tags = {
    "Name" = "e-learning-igw"
  }
}


#Create Public Route and internet Gateway Association
resource "aws_route" "e-learning-pub-rtb1-intgtw" {
  route_table_id         = aws_route_table.e-learning-pub-rtb1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.e-learning-igw.id
}


# Create an Elastic IP (EIP)
resource "aws_eip" "e-learning-eipnew" {
  vpc = true
}


# Create a NAT Gateway in Public Subnet
resource "aws_nat_gateway" "e-learning-natgw" {
  allocation_id = aws_eip.e-learning-eipnew.id
  subnet_id     = aws_subnet.e-learning-pub-sub1new.id

  tags = {
    "Name" = "e-learning-natgw"
  }
}


#Create Public Route and Nat Gateway Association
resource "aws_route" "e-learning-priv-rtb-natgtw" {
  route_table_id         = aws_route_table.e-learning-priv-rtb1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.e-learning-natgw.id
}


# Create security group
resource "aws_security_group" "e-learning-secgrpnew" {
  description = var.e-learning-secgrpnew
  vpc_id      = aws_vpc.e-learning-vpcnew.id

  ingress {
    description = "allow internet access"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  ingress {
    description = "secured HTTPS access"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = {
    "Name" = "${var.e-learning-secgrpnew}"
  }
}


resource "aws_db_subnet_group" "e-learning-db-sub" {
  name = "e-learning-sub-group"
  subnet_ids = [aws_subnet.e-learning-priv-sub1new.id, aws_subnet.e-learning-priv-sub2new.id]
}


#Create RDS Database
resource "aws_db_instance" "elearning-postsql" {
  allocated_storage    = 5
  identifier           = "elearning-postsql"
  engine               = "postgres"
  engine_version       = "14.6"
  instance_class       = var.instance_class
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.e-learning-db-sub.name
  parameter_group_name = aws_db_parameter_group.db-parameter-grp.name
  publicly_accessible =  false
  skip_final_snapshot  = true

  tags = {
    Name = "elearning-postsql"
  }
}

resource "aws_db_parameter_group" "db-parameter-grp" {
  name   = "db-parameter-grp"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}




