#!/bin/bash

# This script will serve as the post-install for AWS PCluster (Ubuntu 20.04)
# Use of hpc stack to install all dependencies to UFS SRWA and RRFS for automated testing

# In parallelcluster/config [fsx myfsx] shared_dir = /scratch1 must be specified for the compute 
# nodes to correctly mount installed dependencies upon launch.


# Install & configure all the requirements in order to follow the Quickstart steps for the UFS SRWA:
# https://ufs-srweather-app.readthedocs.io/en/latest/Quickstart.html & create an environment to run 
# continous integration tests for the regional_workflow

#====================================================================

# Update & General Dependencies 

sudo apt-get update -y
sudo apt-get install -y wget
sudo apt-get install -y git
sudo apt-get install -y curl
sudo apt-get install -y python3.8
# Configure Python 3.8 as default
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1
# Install Ruby as it is a Rocoto dependency
sudo apt-get install -y ruby-full
sudo apt-get install -y ruby-dev

#====================================================================

# IntelOne API
# See https://software.intel.com/content/www/us/en/develop/articles/oneapi-repo-instructions.html

cd /tmp
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
rm GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
sudo apt-get update
sudo apt-get install -y intel-oneapi-dev-utilities intel-oneapi-mpi-devel intel-oneapi-openmp intel-oneapi-compiler-fortran intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic
echo "source /opt/intel/oneapi/setvars.sh" >> ~/.bash_profile

#====================================================================

# Lmod and Lua install & configure into /scratch1/apps (need to be installed in a shared directory)
# See https://lmod.readthedocs.io/en/latest/030_installing.html#install-lua-x-y-z-tar-gz
# apt-get does not work here, as the default apt-get lua & lmod installion (usr/share) is not available to PCluster compute nodes

# LUA
mkdir /scratch1/apps && cd /scratch1/apps
wget https://sourceforge.net/projects/lmod/files/lua-5.1.4.9.tar.bz2
tar xf lua-5.1.4.9.tar.bz2
cd lua-5.1.4.9
./configure --prefix=/scratch1/apps/lua
make
make install

#LMOD
cd /scratch1/apps
wget https://github.com/TACC/Lmod/archive/refs/heads/master.zip -P /scratch1/apps
unzip master.zip
cd Lmod-master/
export PATH=$PATH:/scratch1/apps/lua/bin
export LD_LIBRARY_PATH=/scratch1/apps/lua/lib
export C_INCLUDE_PATH=/scratch1/apps/lua/include
export CPLUS_INCLUDE_PATH=/scratch1/apps/lua/include
./configure --prefix=/scratch1/apps --with-lua=/scratch1/apps/lua/bin/lua --with-lua_include=/scratch1/apps/lua/include --with-luac=/scratch1/apps/lua/bin/luac
make install

sudo ln -s /scratch1/apps/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh

echo "source /scratch1/apps/lmod/lmod/init/bash" >> ~/.bash_profile
# If running interactive shell 
# echo "source /scratch1/apps/lmod/lmod/init/profile" >> ~/.bashrc

#====================================================================

# HPC-STACK BUILD

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
sudo rm -rf /tmp/hpc-stack

#=================================================================

# Clone & Install Rocoto

sudo mkdir /scratch1/rocoto
sudo chmod 777 /scratch1/rocoto
sudo git clone -b develop https://github.com/christopherwharrop/rocoto.git /scratch1/rocoto/develop
sudo git -C /scratch1/rocoto/develop/ checkout tags/1.3.4
pushd /scratch1/rocoto/develop
sudo ./INSTALL

# Make a Module for rocoto
sudo mkdir /scratch1/apps/lmod/lmod/modulefiles/rocoto
sudo chmod 777 /scratch1/apps/lmod/lmod/modulefiles/rocoto
echo "#%Module1.0" > /scratch1/apps/lmod/lmod/modulefiles/rocoto/develop
echo 'prepend-path PATH /scratch1/rocoto/develop/bin' >> /scratch1/apps/lmod/lmod/modulefiles/rocoto/develop
echo 'prepend-path MANPATH /scratch1/rocoto/develop/man' >> /scratch1/apps/lmod/lmod/modulefiles/rocoto/develop
popd

# ====================================================================

# Python Environment

# Miniconda3 install
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
chmod +x ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash

# Make miniconda3 module, regional_workflow & pygraf environments
cd ~/miniconda3
git clone -b rrfs_ci https://github.com/robgonzalezpita/contrib_miniconda3.git
module use -a ~/miniconda3/contrib_miniconda3/modulefiles
module load miniconda3/4.11.0

unset CONDA_ENVS_PATH
unset CONDA_PKGS_PATH

conda env create -f ~/miniconda3/contrib_miniconda3/environments/regional_workflow.yml
conda env create -f ~/miniconda3/contrib_miniconda3/environments/pygraf-rrfs-ci.yml

# ensure the environments are set up correctly
conda activate regional_workflow
conda list 
conda deactivate
conda activate pygraf
conda list
conda deactivate

#====================================================================

# Untar data from s3

cd /scratch1
tar -xvf gst_model_data.tar.gz

# add s3://gsl-ufs/missing/ data to correct directories ()
sudo cp /scratch1/global_co2historicaldata_2021.txt /scratch1/fix/fix_am/fix_co2_update/

sudo cp /scratch1/global_co2historicaldata_2021.txt /scratch1/fix/fix_am/fix_co2_proj/
sudo cp /scratch1/global_co2historicaldata_2021.txt /scratch1/fix/fix_am/co2dat_4a/

# ====================================================================