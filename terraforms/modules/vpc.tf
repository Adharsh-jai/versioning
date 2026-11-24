provider "aws" {
  region = "us-east-1"
}

# 1. vpc


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.client_name}-vpc"
    managed_by = var.managed_by
  }
}

# 2. internet gateway 

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.client_name}-igw"
    managed_by = var.managed_by
  }
}
# 3. public_subnet

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"

    tags = {
        Name = "${var.client_name}-public-subnet"
        managed_by = var.managed_by
    }
}
# 4. private_subnet

# resource "aws_subnet" "private_subnet" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.2.0/24"

#     tags = {
#         Name = "${var.client_name}-private-subnet"
#         managed_by = var.managed_by
#     }
# }
# 5. public_route_table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
 tags = {
    Name = "${var.client_name}-public-route-table"
    managed_by = var.managed_by
  }
}
# 6. private_route_table

# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "${var.client_name}-private-route-table"
#     managed_by = var.managed_by
#   }
# }
# 7. public subnet association
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
# 8. private subnet association
# resource "aws_route_table_association" "private_subnet_association" {
#   subnet_id      = aws_subnet.private_subnet.id
#   route_table_id = aws_route_table.private_route_table.id
# }
# 9. security group

resource "aws_security_group" "web_sg" {
  name        = "${var.client_name}-web-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}   


#sg2 for db server

# resource "aws_security_group" "db_sg" {
#   name        = "${var.client_name}-db-sg"
#   description = "Allow database traffic"
#   vpc_id      = aws_vpc.main.id


#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.1.0/24"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }   
# 10 ec2 instance - web server
resource "aws_instance" "web" {
    ami           = "ami-0aacbf72109c53c0c" # Amazon Linux 2 AMI
    instance_type = "t3.micro"
    subnet_id     = aws_subnet.public_subnet.id
    key_name     = "dev" # Replace with your key pair name
    associate_public_ip_address = true
    security_groups = [aws_security_group.web_sg.id]
    
    tags = {
        Name = "${var.client_name}-web-server"
        managed_by = var.managed_by
    }
  
}
# 11 ec2 instance - database server

# resource "aws_instance" "db" {
#     ami           = "ami-0aacbf72109c53c0c" # Amazon Linux 2 AMI
#     instance_type = "t3.micro"
#     subnet_id     = aws_subnet.private_subnet.id
#     key_name     = "dev" # Replace with your key pair name
#     associate_public_ip_address = false
#     security_groups = [aws_security_group.db_sg.id]
    
#     tags = {
#         Name = "${var.client_name}-db-server"
#         managed_by = var.managed_by
#     }
  
# }

output "web_server_public_ip" {
  value = aws_instance.web.public_ip
}
output "web_server_private_ip" {
  value = aws_instance.web.private_ip
}
# output "db_server_private_ip" {
#   value = aws_instance.db.private_ip
# }