# PROVIDER
provider "aws" {
  region = "us-east-1"
}

# Variables
variable "key_name" {
  default = "new-key"
}
variable "network_address_space" {
  default = "10.1.0.0/16"
}

variable "subnet1_address_space" {
  default = "10.1.0.0/24"
}
variable "subnet2_address_space" {
  default = "10.1.1.0/24"
}

# Data
data "aws_availability_zones" "available" {}

# Resources
## Networking
### VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.network_address_space
  enable_dns_hostnames = "true"
}
### Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
### Routing
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
#### Associating Route tabls to subnets
resource "aws_route_table_association" "rta-subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}
resource "aws_route_table_association" "rta-subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rtb.id
}

### Subnets
resource "aws_subnet" "subnet1" {
  cidr_block              = var.subnet1_address_space
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "subnet2" {
  cidr_block              = var.subnet2_address_space
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[1]
}

### Security Groups 
#### Security group for instances
resource "aws_security_group" "nginx-sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.vpc.id

  # SSH Access to anyone
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Access to anyone
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.network_address_space}"]
  }

  #OUBOUND Internet Acess
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### Security group for load balancer
resource "aws_security_group" "elb-sg" {
  name   = "nginx-elb-sg"
  vpc_id = aws_vpc.vpc.id
  #Allow HTTP to everyone
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
### Instances
resource "aws_instance" "nginx1" {
  ami                    = "ami-0f9ce67dcf718d332"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = ["${aws_security_group.nginx-sg.id}"]
  key_name               = var.key_name

  user_data = file("nginx-install.sh")
  tags = {
    Name = "fromTerraform"
  }
}

resource "aws_instance" "nginx2" {
  ami                    = "ami-0f9ce67dcf718d332"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = ["${aws_security_group.nginx-sg.id}"]
  key_name               = var.key_name

  user_data = file("nginx-install.sh")
  tags = {
    Name = "fromTerraform"
  }
}
### LOAD BALANCER
resource "aws_elb" "web" {
  name = "nginx-elb"

  subnets         = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]
  security_groups = ["${aws_security_group.elb-sg.id}"]
  instances       = ["${aws_instance.nginx1.id}", "${aws_instance.nginx2.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}
# Output
output "aws_elb_public_dns" {
  value = aws_elb.web.dns_name
}