provider "aws" {
  region = "eu-north-1"
  access_key = "AKIAQ3EGS25NPEFQIYFF"
  secret_key = "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"
}

resource "aws_instance" "broadleaf_demo2" {
  ami           = "ami-03238ca76a3266a07"
  instance_type = "t3.micro"
  key_name      = "temp"

  root_block_device {
    volume_size = 20
  }

  security_groups = [aws_security_group.broadleaf_sg2.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo mount -o remount,size=4G /tmp
              sudo fallocate -l 2G /swapfile
              sudo chmod 600 /swapfile
              sudo mkswap /swapfile
              sudo swapon /swapfile
              echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
              sudo yum install -y java maven git
              sudo -i -u ec2-user bash << 'EOF2'
                cd ~
                git clone https://github.com/BroadleafCommerce/DemoSite
                cd DemoSite
                mvn clean install
                cd site
                mvn spring-boot:run -e -Dsolr.solr.home=./solr
              EOF2
            EOF

  tags = {
    Name = "BroadleafDemoInstance2"
  }
}

resource "aws_security_group" "broadleaf_sg2" {
  name        = "broadleaf_sg2"
  description = "Security group for Broadleaf Demo Site"

  ingress {
    description = "Allow HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow remote debug port 8000"
    from_port   = 8000
    to_port     = 8000
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

  tags = {
    Name = "BroadleafDemoSecurityGroup2"
  }
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.broadleaf_demo2.public_ip
}