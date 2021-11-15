#!/bin/bash

# This script will serve as the post-install for AWS PCluster (Ubuntu 20.04)
# Use of hpc stack to install all dependencies to UFS SRWA and RRFS for automated testing

# In parallelcluster/config [fsx myfsx] shared_dir = /scratch1 must be specified for the compute nodes to correctly 
# mount installed dependencies upon launch 

# Install & configure all the requirements in order to follow the Quickstart steps for the UFS SRWA:
# https://ufs-srweather-app.readthedocs.io/en/latest/Quickstart.html

#====================================================================

# General Dependencies & update

cd "$HOME"

sudo apt-get update -y
sudo apt-get install -y wget
sudo apt-get install -y git
sudo apt-get install -y curl
sudo apt-get install -y python3.8
# Configure Python 3.8 as default
update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1
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
# apt-get does not work here, as the default apt-get lua & lmod installion is not available to compute nodes

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
#Below 'exports' might not be needed
export PATH=$PATH:/scratch1/apps/lua/bin
export LD_LIBRARY_PATH=/scratch1/apps/lua/lib
export C_INCLUDE_PATH=/scratch1/apps/lua/include
export CPLUS_INCLUDE_PATH=/scratch1/apps/lua/include
./configure --prefix=/scratch1/apps --with-lua=/scratch1/apps/lua/bin/lua --with-lua_include=/scratch1/apps/lua/include --with-luac=/scratch1/apps/lua/bin/luac
make install

ln -s /scratch1/apps/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh

# echo "cd /scratch1/apps/lmod/8.5.21/init/" >> ~/.bashrc
# echo "source profile" >> ~/.bashrc

echo "source /scratch1/apps/lmod/lmod/init/bash" >> ~/.bash_profile
# echo "source /scratch1/apps/lmod/lmod/init/profile" >> ~/.bash_profile
# If running interactive shell 
# echo "source /scratch1/apps/lmod/lmod/init/profile" >> ~/.bashrc

#====================================================================

# HPC-STACK BUILD

cd /scratch1

source ~/.bash_profile

# sudo su

mkdir /tmp/hpc-stack
# && cd /tmp/hpc-stack
# chmod 777 /tmp/hpc-stack
git clone -b rrfs_ci https://github.com/NOAA-GSL/hpc-stack.git /tmp/hpc-stack
pushd /tmp/hpc-stack
mkdir /scratch1/hpc-stack
sudo chmod 777 /scratch1/hpc-stack
prefix=/scratch1/hpc-stack
python_ver=$( python3 --version | cut -d " " -f2 | cut -d. -f1-2 )
export HPC_COMPILER="intel/2021"
# export HPC_COMPILER="intel/oneapi-2021.4.0"
export HPC_MPI="impi/2021"
# export HPC_COMPILER="impi/oneapi-2021.4.0"
export HPC_PYTHON="python/${python_ver}"
sudo chmod 777 /tmp/hpc-stack/config/config_custom.sh
# echo "source /scratch1/apps/lmod/lmod/init/profile" >> config/config_custom.sh
echo "source /scratch1/apps/lmod/lmod/init/bash" >> config/config_custom.sh
# Make all of the lib scripts a login shell, which sources /scratch1/apps/lmod/lmod/init/profile,
# allowing hpc-intel module to be available
find /tmp/hpc-stack/libs -type f -name "*.sh" | xargs sed -i "s|bin/bash|bin/bash -l|g"
#change build_stack.sh to load appropriate hpc env (line 101) module load hpc => module load hpc/1.2.0
yes | ./setup_modules.sh -c config/config_custom.sh -p "$prefix"
# To make Intel C compiler available, and avoid error when bootstrapping CMake..
# source ~/.bash_profile
./build_stack.sh -p "$prefix" -c config/config_custom.sh -y stack/stack_rrfs_ci.yaml -m
popd
rm -rf /tmp/hpc-Stack

# exit

#====================================================================

# Rocoto

# Clone & install Rocoto
sudo mkdir /scratch1/rocoto
sudo chmod 777 /scratch1/rocoto
git clone -b develop https://github.com/christopherwharrop/rocoto.git /scratch1/rocoto/develop
pushd /scratch1/rocoto/develop
./INSTALL

# Make a Module for rocoto
sudo mkdir /scratch1/apps/lmod/lmod/modulefiles/rocoto
echo "#%Module1.0" > /scratch1/apps/lmod/lmod/modulefiles/rocoto/develop
echo 'prepend-path PATH /scratch1/rocoto/develop/bin' >> /scratch1/apps/lmod/lmod/modulefiles/rocoto/develop
echo 'prepend-path MANPATH /scratch1/rocoto/develop/man' >> /scratch1/apps/lmod/lmod/modulefiles/rocoto/develop


#====================================================================

# Python Environment

mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
chmod +x ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash

conda config --set auto_activate_base false

source ~/.bash_profile

conda install -y jinja2
conda install -y pyyaml
conda install -y -c conda-forge f90nml

#====================================================================

# Clone and Build ufs-srwa & regional_workflow

cd "$HOME"

# Clone, Build, ./manage_externals/checkout_externals of UFS SRWA
# git clone -b rrfs_ci https://github.com/NOAA-GSL/ufs-srweather-app.git
git clone -b linux_target https://github.com/robgonzalezpita/ufs-srweather-app.git
cd ufs-srweather-app
./manage_externals/checkout_externals

# Checkout up to date branch (dev/emc) of ufs-weather-model/FV3 for bugfix
cd src/ufs-weather-model/FV3/
git clone https://github.com/NOAA-GFDL/GFDL_atmos_cubed_sphere.git atmos_cubed_sphere
cd atmos_cubed_sphere
git checkout dev/emc

cd ~/ufs-srweather-app/

# Scratch1 is mounted upon PCluster creation, so we can source this file directly 
source /scratch1/build_linux_intel.env

mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=.. | tee log.cmake
make -j4 >& build.out &

#====================================================================

# Generate Workflow Experiment following these steps:

# https://ufs-srweather-app.readthedocs.io/en/ufs-v1.0.1/Quickstart.html#generate-the-workflow-experiment

