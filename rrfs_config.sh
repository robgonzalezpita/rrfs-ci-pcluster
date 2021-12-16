# config.sh file used in regional_workflow/ush

MACHINE="LINUX"
ACCOUNT="my_account"
EXPT_SUBDIR="pcluster_test"
EXPT_BASEDIR="/scratch1/expts_dir"

WORKFLOW_MANAGER="rocoto"
SCHED="slurm"

# I_MPI_PMI_LIBRARY="/opt/slurm/lib/libpmi2.so"
# I_MPI_PMI2="yes"
# I_MPI_CC="icc"
# I_MPI_ROOT="/opt/intel/compilers_and_libraries_2020.2.254/linux/mpi"
# I_MPI_F90="ifort"
# I_MPI_HYDRA_PMI_CONNECT="alltoall"
# I_MPI_HYDRA_BRANCH_COUNT="128"
# I_MPI_OFI_PROVIDER="tcp"

# RUN_CMD_UTILS="srun"
# RUN_CMD_FCST="srun"
# RUN_CMD_POST="srun"

LMOD_PATH="/scratch1/apps/lmod/lmod/init/bash"
# LMOD_PATH="/scratch1/apps/lmod/lmod/init/sh"
BUILD_ENV_FN="build_linux_intel.env"

COMPILER="intel"
VERBOSE="TRUE"

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
QUILTING="TRUE"

DO_ENSEMBLE="FALSE"
NUM_ENS_MEMBERS="2"

CCPP_PHYS_SUITE="FV3_GFS_v15p2"
FCST_LEN_HRS="24"
LBC_SPEC_INTVL_HRS="6"

DATE_FIRST_CYCL="20190615"
DATE_LAST_CYCL="20190615"
CYCL_HRS=( "00" )

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"

FV3GFS_FILE_FMT_ICS="grib2"
FV3GFS_FILE_FMT_LBCS="grib2"

WTIME_RUN_FCST="01:00:00"

MODEL="FV3_GFS_v15p2_CONUS_25km"
METPLUS_PATH="path/to/METPlus"
MET_INSTALL_DIR="path/to/MET"
CCPA_OBS_DIR="/path/to/processed/CCPA/data"
MRMS_OBS_DIR="/path/to/processed/MRMS/data"
NDAS_OBS_DIR="/path/to/processed/NDAS/data"

NCORES_PER_NODE=8
# NCORES_PER_NODE=36 # Up to 72 for c5n18xlarge instances?

USE_CRON_TO_RELAUNCH="TRUE"
CRON_RELAUNCH_INTVL_MNTS="01"

PARTITION_DEFAULT="compute"
QUEUE_DEFAULT="compute"
PARTITION_HPSS="compute"
QUEUE_HPSS="compute"
PARTITION_FCST="compute"
QUEUE_FCST="compute"

RUN_TASK_MAKE_GRID="TRUE"
RUN_TASK_MAKE_OROG="TRUE"
RUN_TASK_MAKE_SFC_CLIMO="TRUE"
RUN_TASK_GET_OBS_CCPA="FALSE"
RUN_TASK_GET_OBS_MRMS="FALSE"
RUN_TASK_GET_OBS_NDAS="FALSE"
RUN_TASK_VX_GRIDSTAT="FALSE"
RUN_TASK_VX_POINTSTAT="FALSE"
RUN_TASK_VX_ENSGRID="FALSE"
RUN_TASK_VX_ENSPOINT="FALSE"

# The following are specifically for using the FSX mount of the /scratch1 dir (s3://gsl-ufs)
# From PCLUSTER, cd /scratch1 && `tar -xvf gst_model_data.tar.gz`
FIXgsm=${FIXgsm:-"/scratch1/fix/fix_am"}
TOPO_DIR=${TOPO_DIR:-"/scratch1/fix/fix_orog"}
SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"/scratch1/fix/fix_sfc_climo"}
FIXLAM_NCO_BASEDIR=${FIXLAM_NCO_BASEDIR:-"/scratch1"}

#
# Uncomment the following line in order to use user-staged external model 
# files with locations and names as specified by EXTRN_MDL_SOURCE_BASEDIR_ICS/
# LBCS and EXTRN_MDL_FILES_ICS/LBCS.
#
USE_USER_STAGED_EXTRN_FILES="TRUE"
#
# The following is specifically for Hera.  It will have to be modified
# if on another platform, using other dates, other external models, etc.
# Uncomment the following EXTRN_MDL_*_ICS/LBCS only when USE_USER_STAGED_EXTRN_FILES=TRUE
#
EXTRN_MDL_SOURCE_BASEDIR_ICS="/scratch1/model_data/FV3GFS"
EXTRN_MDL_FILES_ICS=( "gfs.pgrb2.0p25.f000" )
EXTRN_MDL_SOURCE_BASEDIR_LBCS="/scratch1/model_data/FV3GFS"
EXTRN_MDL_FILES_LBCS=( "gfs.pgrb2.0p25.f006" "gfs.pgrb2.0p25.f012" "gfs.pgrb2.0p25.f018" "gfs.pgrb2.0p25.f024" \
                      "gfs.pgrb2.0p25.f030" "gfs.pgrb2.0p25.f036" "gfs.pgrb2.0p25.f042" "gfs.pgrb2.0p25.f048" )
