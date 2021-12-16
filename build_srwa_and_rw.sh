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

# source /scratch1/build_linux_intel.env
source ~/rrfs-ci-pcluster/build_linux_intel.env

mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=.. | tee log.cmake
make -j4 >& build.out &

# #====================================================================

# # Untar data from s3 (either done here or in post_install script)

# cd /scratch1
# tar -xvf gst_model_data.tar.gz

# # add s3://gsl-ufs/missing/ data to correct directories ()
# sudo cp /scratch1/global_co2historicaldata_2021.txt /scratch1/fix/fix_am/
# sudo cp /scratch1/global_co2historicaldata_2021.txt /scratch1/fix/fix_am/fix_co2_proj/
# sudo cp /scratch1/global_co2historicaldata_2021.txt /scratch1/fix/fix_am/co2dat_4a/

# # ====================================================================

# Generate Workflow Experiment following these steps:
# https://ufs-srweather-app.readthedocs.io/en/ufs-v1.0.1/Quickstart.html#generate-the-workflow-experiment


cd ~/ufs-srweather-app/regional_workflow/ush
cp ~/rrfs-ci-pcluster/rrfs_config.sh config.sh
# cp ~/rrfs-ci-pcluster/config_defaults.sh config_defaults.sh

# Set up python environment in creating a ../../env/wflow_linux.env file in the R_W repo

cp ~/rrfs-ci-pcluster/wflow_linux.env ~/ufs-srweather-app/env/wflow_linux.env

cp ~/rrfs-ci-pcluster/build_linux_intel.env ~/ufs-srweather-app/env/build_linux_intel.env

# add following to ~/ufs-srweather-app/regional_workflow/ush/load_modules_run_task.sh (line 105)?
#
#   "LINUX")
    # . /scratch1/apps/lmod/lmod/init/sh
    # ;;

# cp ~/rrfs-ci-pcluster/load_modules_run_task.sh ~/ufs-srweather-app/regional_workflow/ush/load_modules_run_task.sh

# #====================================================================
# MPI ERRORS -  Debugging notes

# In ush/config_defaults.sh, add the following (ln. 170,171)
# +I_MPI_OFI_PROVIDER=""
# +I_MPI_PMI_LIBRARY=""
# +I_MPI_CC=""
# +I_MPI_ROOT=""
# +I_MPI_PMI2=""
# +I_MPI_F90=""
# +I_MPI_HYDRA_PMI_CONNECT=""
# +I_MPI_HYDRA_BRANCH_COUNT=""

# Abort(1) on node 0 (rank 0 in comm 496): application called MPI_Abort(comm=0x84000002, 1) - process 0
# srun: error: compute-dy-c5n18xlarge-1: tasks 0-11: Exited with exit code 1

# module load intelmpi

# module load libfabric

# env | grep I_MPI

# IN ~/ufs-srweather-app/regional_workflow/scripts/exregional_run_post.sh add 
#    "LINUX")
# +    ulimit -s unlimited
# +    ulimit -a
#      APRUN=$RUN_CMD_POST
#      ;;

# In /ush/launch_FV3LAM_wflow.sh ???
# +export I_MPI_PMI_LIBRARY=/opt/slurm/lib/libpmi2.so



# #====================================================================

# Generate the workflow

source ../../env/wflow_linux.env
./generate_FV3LAM_wflow.sh

#====================================================================

# Run the Workflow Using Rocoto
# https://ufs-srweather-app.readthedocs.io/en/ufs-v1.0.1/Quickstart.html#run-the-workflow-using-rocoto

cd $EXPTDIR
./launch_FV3LAM_wflow.sh

#====================================================================
