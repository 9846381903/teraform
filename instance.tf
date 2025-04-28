provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t2.micro"
  key_name      = "attendance-key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<EOF
#!/bin/bash
sudo systemctl stop apache2 || true
sudo systemctl disable apache2 || true

${local.db_setup_script}
${local.php_setup_script}
${local.nginx_setup_script}
${local.monitoring_setup_script}
EOF

  tags = {
    Name = "WebServer"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow SSH, HTTP, Node Exporter, Prometheus, and Grafana traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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
