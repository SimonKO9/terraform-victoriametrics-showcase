terraform {
  required_version = ">= 1.0"

  backend "s3" {}
}

provider "aws" {
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = var.env_name
      Owner       = var.extra_tag_owner
    }
  }
}

data "aws_default_tags" "this" {}

module "foundation" {
  source          = "./modules/foundation"
  vpc_id          = var.vpc_id
  bastion_sg_name = var.bastion_sg_name
}

module "vm" {
  source = "./modules/victoriametrics"

  vm_instance_type = var.vm_instance_type
  vpc_id           = var.vpc_id
  vm_ami_id        = module.foundation.ami_id
  vm_disk_size     = var.vm_disk_size
  vm_subnet_id     = module.foundation.private_subnet_ids[0]
  env_name         = var.env_name
  vm_ssh_key_name  = var.vm_ssh_key_name

  bastion_security_group_id = module.foundation.bastion_security_group_id

  vm_instance_tags = concat(
    [for key, value in data.aws_default_tags.this.tags : { key = key, value = value, propagate_at_launch = true }],
    [
      {
        key                 = "Project"
        value               = "Metrics"
        propagate_at_launch = true
      }
    ]
  )
}