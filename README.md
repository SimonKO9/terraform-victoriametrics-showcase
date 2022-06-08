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