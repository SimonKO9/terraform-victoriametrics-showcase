data "aws_security_group" "default" {
  name   = "default"
  vpc_id = var.vpc_id
}

data "template_file" "userdata" {
  template = file("${path.module}/user_data.sh")
  vars = {
    EBS_VOLUME = aws_ebs_volume.vm_data.id
  }
}

data "aws_subnet" "vm_subnet" {
  id = var.vm_subnet_id
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

locals {
  resource_name = "${var.env_name}-victoriametrics"
}

resource "aws_ebs_volume" "vm_data" {
  availability_zone = data.aws_subnet.vm_subnet.availability_zone
  encrypted         = true
  size              = var.vm_disk_size
  type              = "gp2"
}

resource "aws_security_group" "victoriametrics" {
  name   = local.resource_name
  vpc_id = data.aws_vpc.this.id

  ingress {
    from_port       = 22
    protocol        = "TCP"
    to_port         = 22
    security_groups = [var.bastion_security_group_id]
  }

  ingress {
    from_port   = 8428
    protocol    = "TCP"
    to_port     = 8428
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "ALL"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_policy" "victoriametrics_attach_vol" {
  name   = "${local.resource_name}-attach-vol"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ec2:AttachVolume",
            "Resource": [
                "arn:aws:ec2:*:535376654616:instance/*",
                "arn:aws:ec2:*:535376654616:volume/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVolumes"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_policy_attachment" "victoriametrics_attach_vol" {
  name       = "${local.resource_name}-attach-vol"
  policy_arn = aws_iam_policy.victoriametrics_attach_vol.arn
  roles      = [aws_iam_role.victoriametrics.id]
}

resource "aws_iam_role" "victoriametrics" {
  name               = local.resource_name
  description        = "Role for VictoriaMetrics EC2 instance."
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "victoriametrics" {
  name = local.resource_name
  role = aws_iam_role.victoriametrics.id
}

resource "aws_launch_configuration" "victoriametrics" {
  name_prefix          = "local.resource_name"
  image_id             = var.vm_ami_id
  instance_type        = var.vm_instance_type
  user_data            = data.template_file.userdata.rendered
  security_groups      = [aws_security_group.victoriametrics.id]
  key_name             = var.vm_ssh_key_name
  iam_instance_profile = aws_iam_instance_profile.victoriametrics.id

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }
}

resource "aws_autoscaling_group" "victoriametrics" {
  name                 = local.resource_name
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = toset([var.vm_subnet_id])
  launch_configuration = aws_launch_configuration.victoriametrics.id

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tags"]
  }

  tags = toset(var.vm_instance_tags)

  lifecycle {
    create_before_destroy = true
  }
}