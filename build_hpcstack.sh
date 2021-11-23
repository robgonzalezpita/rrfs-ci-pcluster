#!/bin/bash -l

# External Script to build hpc-stack 

cd /scratch1
source ~/.bash_profile
mkdir /tmp/hpc-stack && cd /tmp/hpc-stack
sudo chmod 777 /tmp/hpc-stack
git clone -b rrfs-ci https://github.com/robgonzalezpita/hpc-stack.git /tmp/hpc-stack
pushd /tmp/hpc-stack
mkdir /scratch1/hpc-stack
sudo chmod 777 /scratch1/hpc-stack
prefix=/scratch1/hpc-stack
yes | ./setup_modules.sh -c config/config_pcluster.sh -p "$prefix"
./build_stack.sh -p "$prefix" -c config/config_pcluster.sh -y stack/stack_rrfs_ci.yaml -m
popd
# sudo rm -rf /tmp/hpc-stack
