variable "env_name" {
  description = "A short, lowercase descriptive name of the environment, e.g. dev, stg, prod etc."
}

variable "extra_tag_owner" {
  description = "Owner managing the VPC and related resources."
}

variable "vpc_id" {
  description = "VPC in which to create the resources."
}

variable "bastion_sg_name" {
  description = "Name of bastion host's security group."
}
variable "vm_instance_type" {
  description = "Instance type to use for victoriametrics box."
}

variable "vm_disk_size" {
  type = number
}

variable "vm_ssh_key_name" {

}