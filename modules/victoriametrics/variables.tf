variable "vpc_id" {
  description = "ID of the VPC in which to provision resources."
}

variable "vm_ami_id" {
  description = "ID of the AMI intended for VictoriaMetrics box."
}

variable "vm_instance_type" {
  description = "Instance type for VictoriaMetrics box."
}

variable "vm_disk_size" {
  type        = number
  description = "Disk size for data volume for VictoriaMetrics box, in GB."
}

variable "env_name" {
  description = "Name of the environment, e.g. dev."
}

variable "vm_subnet_id" {
  description = "Subnet in which to deploy the service to."
}

variable "bastion_security_group_id" {
  description = "ID of the security group defined for bastion hosts."
}

variable "vm_ssh_key_name" {
  description = "SSH key pair name to use for accessing VictoriaMetrics box."
}

variable "vm_instance_tags" {
  type = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))

  description = "Tags to apply to VictoriaMetrics instance."
}