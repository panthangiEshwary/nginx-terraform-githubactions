provider "aws" {
  region = var.region
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP"

  ingress {
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
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y
              systemctl start nginx
              echo "<h1>Hello from NGINX + Terraform + GitHub Actions</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "NginxWebServer"
  }
}
