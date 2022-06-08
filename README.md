Terraform VictoriaMetrics
=========================

#  Overview
This repository shows how to provision a VictoriaMetrics box with persistent data.

VictoriaMetrics box is put behind an auto-scaling group of size=1 to ensure it's running. Persistent volume is mounted dynamically using user data script.

The box is installed on a randomly chosen (first returned) private subnet. 

# Connectivity

All outbound traffic is permitted.

SSH access is permitted from bastion host.
VictoriaMetrics exposes API at port 8428 and is accessible from within the VPC.

# Modules

The project consists of the following modules:
- foundation,
- victoriametrics.

## Foundation module

Foundation module acts as a bridge between the environment and existing resources and specific modules. It serves a similar purpose to Terraform remote state. Terraform remote state has its caveats and is not always easily accessible.

## VictoriaMetrics module

VictoriaMetrics module defines everything necessary to run VictoriaMetrics: IAM policy, role, instance profile, persistent EBS drive and auto-scaling group (with size = 1).