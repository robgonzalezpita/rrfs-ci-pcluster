# rrfs-ci-pcluster

## Parallel Cluster CI configuration for the UFS SRWA &amp; RRFS.

Necessary scripts and configuration files to setup a PCluster to run the SRWA and RRFS.
Ultimately the configured PCluster will be a Github Actions Self hosted runner and run the CI for the regional_workflow repository.


# Getting Started 

Ensure [AWS cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html) and [PCluster version 2](https://docs.aws.amazon.com/parallelcluster/latest/ug/getting_started.html) are installed locally with the appropriate permissions to CloudFormation resources (necessary to launch and use AWS ParallelCluster).

Create a ~/.parallelcluster/config file similar to the [config](config) file in this repo

Create a new ParallelCluster:
```
pcluster create <clustername>
```

SSH into the cluster:
```
ssh ubuntu@<ip_address>
```

You will get a message about the authenticity of the host, enter `yes`.

## Once connected to the PCluster Head node

Install git:

```
sudo apt-get install git
```

Clone and enter this repository:
```
git clone -b main https://github.com/robgonzalezpita/rrfs-ci-pcluster.git
cd rrfs-ci-pcluster
```

Source the post_install.sh script:
```
source rrfs_ci_post_install.sh 2>&1 | tee rrfs_ci_post_install_build.out
```

## Build the model and run the workflow

Follow the general outline of commented code in [post_install.sh](post_install.sh) to setup Python Environment, Clone ufs-srwa, [Generate the Workflow Experiment](https://ufs-srweather-app.readthedocs.io/en/ufs-v1.0.1/Quickstart.html#generate-the-workflow-experiment), and [Run the Workflow Using Rocoto](https://ufs-srweather-app.readthedocs.io/en/ufs-v1.0.1/Quickstart.html#run-the-workflow-using-rocoto)


### Delete the PCluster:
```
pcluster delete <clustername>
```
