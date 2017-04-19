#!/bin/bash

set -x
set -e

# Use a simple mapping of one GPU per process.
CUDA_VISIBLE_DEVICES=${OMPI_COMM_WORLD_LOCAL_RANK}

GPUS_PER_NODE=4

if [ ${OMPI_COMM_WORLD_RANK} -ge 2 ]; then
  let TASK_ID=${OMPI_COMM_WORLD_RANK}
  TASK_TYPE="worker"
elif [ ${OMPI_COMM_WORLD_RANK} -eq 0 ]; then
  TASK_ID=0
  TASK_TYPE="ps"
elif [ ${OMPI_COMM_WORLD_RANK} -eq 1 ];then
  TASK_ID=1
  TASK_TYPE="master"
fi

if [ ! -z "${DEBUG}" ]; then
    echo "WORLD RANK: ${OMPI_COMM_WORLD_RANK}"
    echo "GPUS_PER_NODE: ${GPUS_PER_NODE}"
    echo "CUDA DEVICES: ${CUDA_VISIBLE_DEVICES} on $(hostname)"
    echo "Task ID[$(hostname)]: ${TASK_TYPE} ${TASK_ID}"
fi

export CUDA_VISIBLE_DEVICES
export TASK_TYPE
export TASK_ID

if [ "$TASK_TYPE" = "worker" ]; then
  sleep 2
fi

# Learn runner will read the TF_CONFIG object
/usr/local/distributed-tensorflow/scripts/start_wrapper.sh "${TASK_TYPE}" "${TASK_ID}"
