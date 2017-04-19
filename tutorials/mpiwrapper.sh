#!/bin/bash

set -x
set -e

GPUS_PER_NODE=4
echo "WORLD RANK: ${OMPI_COMM_WORLD_RANK}"
echo "GPUS_PER_NODE: ${GPUS_PER_NODE}"

#(( CUDA_VISIBLE_DEVICES = ${OMPI_COMM_WORLD_RANK} % ${GPUS_PER_NODE} ))
CUDA_VISIBLE_DEVICES=${OMPI_COMM_WORLD_LOCAL_RANK}

export CUDA_VISIBLE_DEVICES
echo "CUDA DEVICES: ${CUDA_VISIBLE_DEVICES} on $(hostname)"

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

echo "Task ID[$(hostname)]: ${TASK_TYPE} ${TASK_ID}"

export TASK_TYPE
export TASK_ID
export TF_CONFIG=$(python /usr/local/distributed-tensorflow/tutorials/gen_config.py)

if [ "$TASK_TYPE" = "worker" ]; then
  sleep 2
fi

# Learn runner will read the TF_CONFIG object
/bin/bash `dirname $0`/start_wrapper.sh "${TASK_TYPE}" "${TYPE_ID}"

