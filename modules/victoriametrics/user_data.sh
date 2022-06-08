#!/bin/sh

set -eu

yum -y update
yum install -y awscli python3-pip
amazon-linux-extras install -y docker
usermod -aG docker ec2-user

systemctl enable docker
systemctl start docker

instance_id=$(ec2-metadata --instance-id | sed 's/instance-id: \(.*\)$/\1/')
region=$(ec2-metadata --availability-zone | sed 's/placement: \(.*\).$/\1/')

aws ec2 attach-volume --instance-id $instance_id --volume-id ${EBS_VOLUME} --device /dev/sdf --region $region
aws ec2 wait volume-in-use --volume-ids ${EBS_VOLUME} --region $region

until [ -L "/dev/sdf" ]; do
  echo "Waiting for /dev/sdf"
  sleep 5
done

DEVICE=$(readlink -f /dev/sdf)
MOUNT_POINT=/data


echo "Setting up device $DEVICE"

cp /etc/fstab /etc/fstab.orig

UUID=$(blkid | grep $DEVICE | awk -F '\"' '{print $2}')

if [ -z "$UUID" ]; then
  echo "There's no file system on device $DEVICE, making one."
  mkfs -t ext4 $DEVICE
  UUID=$(blkid | grep $DEVICE | awk -F '\"' '{print $2}')
fi

echo "Setting up device $DEVICE (UUID=$UUID) to $MOUNT_POINT"

mkdir -p $MOUNT_POINT
mount $DEVICE $MOUNT_POINT
echo "UUID=$UUID  $MOUNT_POINT  ext4  defaults,nofail  0  2" >> /etc/fstab
mkdir -p $MOUNT_POINT/victoria-metrics-data

docker run -d \
  -v $MOUNT_POINT/victoria-metrics-data:/victoria-metrics-data \
  -p 8428:8428 \
  --name victoriametrics \
  victoriametrics/victoria-metrics
