terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg-${random_id.suffix.hex}"
  description = "Allow HTTP"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    description = "Allow SSH"
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

resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

user_data = <<-EOF
  #!/bin/bash
  apt update -y
  apt install nginx -y
  systemctl start nginx
  systemctl enable nginx
  echo "<h1>Hello from NGINX + Terraform + GitHub Actions </h1>" > /var/www/html/index.html
EOF
  tags = {
    Name = "NginxWebServer"
  }
}
