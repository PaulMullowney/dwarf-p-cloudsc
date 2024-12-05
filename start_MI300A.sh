#!/bin/bash

APU_LIST=(0 1 2 3)                  # APU index list
NUM_GPUS=4  # Number of APUs requested
MY_RANK=0

ranks_per_gpu=1
my_gpu=0

export ROCR_VISIBLE_DEVICES=${APU_LIST[$my_gpu]}

echo "Number of ranks per APU: ${ranks_per_gpu}"
echo "Rank $MY_RANK APU device id: $ROCR_VISIBLE_DEVICES"

# Set huge pages
sudo cat /sys/kernel/mm/transparent_hugepage/enabled
sudo chmod go+w /sys/kernel/mm/transparent_hugepage/enabled
sudo echo always > /sys/kernel/mm/transparent_hugepage/enabled
sudo chmod go-w /sys/kernel/mm/transparent_hugepage/enabled
sudo cat /sys/kernel/mm/transparent_hugepage/enabled

#export HSA_XNACK=0
numactl -m ${APU_LIST[$my_gpu]} bin/dwarf-cloudsc-hip-hoist 1 262144 64 2

# Revert huge pages
sudo chmod go+w /sys/kernel/mm/transparent_hugepage/enabled
sudo echo never > /sys/kernel/mm/transparent_hugepage/enabled
sudo chmod go-w /sys/kernel/mm/transparent_hugepage/enabled
sudo cat /sys/kernel/mm/transparent_hugepage/enabled


