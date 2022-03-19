#!/bin/bash

# Call this script from regional_workflow/tests/
# can call ./get_expts_status.sh /scratch1/expts_dir/ to get status of all experiments

# For each finished experiment (finished expts are sent to /tests/test_log), check the log file produced to get success/failure
for FILE in ${PWD}/test_log/*; do
  echo $FILE;
  logfile=$FILE
  expt=${FILE##*/}
  echo $expt
#   while [[ true ]]; do
#     # sleep 20
    tail -1 $logfile | grep -q ": SUCCESS"
    if [[ $? -ne 1 ]]; then
      echo "Workflow Generation for $expt Successful"
    #   exit 0
    else 
      echo "Workflow Generation for $expt Failed"
    #   exit 1
    fi
#   done

done