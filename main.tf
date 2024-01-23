terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  
}


resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}


resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table_association" "rtba1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "rtba2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rtb.id
}
resource "aws_security_group" "sg" {
  name    = "sgg"
  description = "Allow HTTP, SSH inbound traffic"
  vpc_id = aws_vpc.myvpc.id


 ingress {
    description  = "HTTP"
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]

} 

 ingress {
    description  = "SSH"
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]

}
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]

 tags = {
   Name = "Mysecuritygroup"
 }

  
}


resource "aws_s3_bucket" "s3b" {
  bucket = "senaikeabbeys3bucket2024"
  
}


resource "aws_instance" "webserver1" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.sub1.id
  user_data = <<-EOF
      #!/bin/sh
      sudo apt-get update
      sudo apt install -y apache2
      sudo systemctl status apache2
      sudo systemctl start apache2
      sudo chown -R $USER:$USER /var/www/html
      sudo echo "<html><body><h1>Hello senaike abbey</h1></body></html>" > /var/www/html/index.html
      EOF

}


resource "aws_instance" "webserver2" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.sub2.id
   user_data = <<-EOF
      #!/bin/sh
      sudo apt-get update
      sudo apt install -y apache2
      sudo systemctl status apache2
      sudo systemctl start apache2
      sudo chown -R $USER:$USER /var/www/html
      sudo echo "<html><body><h1>gh repo clone Oluwasetemi/My_AltSchool_Project</h1></body></html>" > /var/www/html/index.html
      EOF
} 
# loadbalancer application

resource "aws_lb" "my-alb" {
  name            = "my-alb"
  internal        = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.sg.id]
  subnets         = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "my-alb"
  }
}


resource "aws_lb_target_group" "tg" {
  name = "mytg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myvpc.id

  health_check {
    path =  "/"
    port = "traffic-port"
  }

  
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver1.id
  port = 80

  
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver2.id
  port = 80
  
  
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.my-alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type = "forward"
  }
}
