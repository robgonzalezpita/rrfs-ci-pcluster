#!/bin/bash

# Rough outline of cloning and buildling ufs srwa and regional workflow

#====================================================================

# Clone and Build ufs-srwa & regional_workflow

cd "$HOME"

# Clone, Build, ./manage_externals/checkout_externals of UFS SRWA
# git clone -b rrfs_ci https://github.com/NOAA-GSL/ufs-srweather-app.git
git clone -b linux_target https://github.com/robgonzalezpita/ufs-srweather-app.git
# which points to Christina's RRFS linux_target branch https://github.com/christinaholtNOAA/regional_workflow/tree/linux_target
cd ufs-srweather-app
./manage_externals/checkout_externals

# Checkout up to bugfix/namelist-io branch of Chris'ufs-weather-model/FV3/atmos_cubed_sphere for bugfix
cd src/ufs-weather-model/FV3/
mv atmos_cubed_sphere atmos_cubed_sphere.orig
git clone https://github.com/christopherwharrop-noaa/GFDL_atmos_cubed_sphere.git atmos_cubed_sphere
cd atmos_cubed_sphere
git checkout bugfix/namelist-io

cd ~/ufs-srweather-app/

# Set up the Build Environment
# Scratch1 is mounted upon PCluster creation, so we can source this file directly 
source /scratch1/build_linux_intel.env

mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=.. | tee log.cmake
make -j4 >& build.out &

# #====================================================================

# # Untar data from s3

# cd /scratch1
# tar -xvf gst_model_data.tar.gz

# # add s3://gsl-ufs/missing/ data to correct directories ()
# sudo cp /scratch1/missing/global_co2historicaldata_2021.txt /scratch1/fix/fix_am/

# # ====================================================================

# Generate Workflow Experiment following these steps:
# https://ufs-srweather-app.readthedocs.io/en/ufs-v1.0.1/Quickstart.html#generate-the-workflow-experiment

cd ~/ufs-srweather-app/regional_workflow/ush
cp ~/rrfs-ci-pcluster/rrfs_config.sh config.sh

# Set up python environment in creating a ../../env/wflow_linux.env file in the R_W repo

cp ~/rrfs-ci-pcluster/wflow_linux.env ~/ufs-srweather-app/env/wflow_linux.env

cp /scratch1/build_linux_intel.env ~/ufs-srweather-app/env/build_linux_intel.env
# cp ~/rrfs-ci-pcluster/build_linux_intel.env ~/ufs-srweather-app/env/build_linux_intel.env

# add following to ~/ufs-srweather-app/regional_workflow/ush/load_modules_run_task.sh (line 105)?
#
#   "LINUX")
    # . /scratch1/apps/lmod/lmod/init/sh
    # ;;

# In ush/config_defaults.sh, change the following (ln. 170,171)
# -RUN_CMD_FCST="mpirun -np \${PE_MEMBER01}"
# -RUN_CMD_POST="mpirun -np 1"
# +RUN_CMD_FCST="srun"
# +RUN_CMD_POST="srun"


# change expt_dir/<expt>/var_dfns.sh ? variable in ln 2111


./generate_FV3LAM_wflow.sh

#====================================================================

# Run the Workflow Using Rocoto
# https://ufs-srweather-app.readthedocs.io/en/ufs-v1.0.1/Quickstart.html#run-the-workflow-using-rocoto


cd $EXPTDIR
./launch_FV3LAM_wflow.sh

# Add to crontab? (Or is this done automatically)
*/1 * * * * cd /home/ubuntu/expt_dirs/pcluster_test && ./launch_FV3LAM_wflow.sh


#====================================================================
