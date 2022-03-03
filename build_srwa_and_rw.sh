#!/bin/bash

# Rough outline of cloning and buildling ufs srwa and regional workflow

# source ~/.bash_profile

#====================================================================

# Clone and Build ufs-srwa & regional_workflow

cd "$HOME"

# Clone, Build, ./manage_externals/checkout_externals of UFS SRWA
git clone -b rrfs_ci https://github.com/NOAA-GSL/ufs-srweather-app.git
# git clone -b linux_target https://github.com/robgonzalezpita/ufs-srweather-app.git
cd ufs-srweather-app
./manage_externals/checkout_externals

# Set up the Build Environment

source /scratch1/apps/lmod/lmod/init/bash

# source /scratch1/build_linux_intel.env
source ~/rrfs-ci-pcluster/build_linux_intel.env

mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=.. | tee log.cmake
make -j4 >& build.out &

#====================================================================

# Generate Workflow Experiment following these steps:
# https://ufs-srweather-app.readthedocs.io/en/ufs-v1.0.1/Quickstart.html#generate-the-workflow-experiment


cd ~/ufs-srweather-app/regional_workflow/ush
cp ~/rrfs-ci-pcluster/rrfs_config.sh config.sh
#cp ~/rrfs-ci-pcluster/config_defaults.sh config_defaults.sh

# Set up python environment in copying the ../../env/wflow_linux.env file to the ufs-srwa repo

cp ~/rrfs-ci-pcluster/wflow_linux.env ~/ufs-srweather-app/env/wflow_linux.env

cp ~/rrfs-ci-pcluster/build_linux_intel.env ~/ufs-srweather-app/env/build_linux_intel.env

#====================================================================

# Generate the workflow

source ../../env/wflow_linux.env
./generate_FV3LAM_wflow.sh

#====================================================================

# Run the Workflow Using Rocoto
# https://ufs-srweather-app.readthedocs.io/en/ufs-v1.0.1/Quickstart.html#run-the-workflow-using-rocoto

cd /scratch1/expts_dir/pcluster_test
./launch_FV3LAM_wflow.sh

#====================================================================
