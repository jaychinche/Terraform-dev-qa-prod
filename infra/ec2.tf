resource "aws_key_pair" "my_key" {
  key_name   = "${var.env}-infra-app-keypair"
  public_key = file("${path.module}/terra-key-ec2.pub")
  tags={
    Enviroment=var.env
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
    Enviroment = var.env
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "${var.env}-infra-app-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_default_vpc.default.id
  tags = {
    Name = "allow_tls"
    Enviroment = var.env
  }
    ingress {
       from_port = 22
       to_port = 22
       protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
       description = "Allow SSH from anywhere"
    }
    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP from anywhere"
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS from anywhere"
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
    }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

resource "aws_instance" "my_instance" {
    count                 = var.instance_count
    ami                    = "ami-0532be01f26a3de55"
    instance_type          = var.instance_type
    key_name               = aws_key_pair.my_key.key_name
    vpc_security_group_ids = [aws_security_group.allow_tls.id]
    associate_public_ip_address = true

    root_block_device {
        volume_size           = 20
        volume_type           = "gp2"
        delete_on_termination = true
    }
    tags = {
        Name = "${var.env}-infra-app-ec2"
        Enviroment = var.env
    }
}




