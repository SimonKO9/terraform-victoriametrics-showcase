data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnets" "private_subnets" {
  tags = {
    Tier = "Private"
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_security_group" "bastion" {
  name = var.bastion_sg_name
}

output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}

output "private_subnet_ids" {
  value = data.aws_subnets.private_subnets.ids
}

output "bastion_security_group_id" {
  value = data.aws_security_group.bastion.id
}