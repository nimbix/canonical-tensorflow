#!/bin/bash

set -x

GPUS_PER_NODE=4
let CUDA_VISIBLE_DEVICES=${OMPI_COMM_WORLD_RANK} % ${GPUS_PER_NODE}

# One CUDA device per worker
if [ ${OMPI_COMM_WORLD_RANK} -ge 2 ]; then
  let TASK_ID=${OMPI_COMM_WORLD_RANK}-2
  TASK_TYPE="worker"
elif [ ${OMPI_COMM_WORLD_WORLD_RANK} -eq 0 ]; then
  TASK_ID=0
  TASK_TYPE="ps"
elif [ ${OMPI_COMM_WORLD_WORLD_RANK} -eq 1 ];then
  TASK_ID=1
  TASK_TYPE="master"
fi

echo "Task ID[$(hostname)]: ${TASK_ID}"

export TASK_TYPE
export TASK_ID
export TF_CONFIG=$(python /usr/local/distributed-tensorflow/tutorials/gen_config.py)

if [ "$TASK_TYPE" = "worker" ]; then
  sleep 5
fi

# Learn runner will read the TF_CONFIG object
exec /usr/local/distributed-tensorflow/tensorflow.sh $@ >/dev/null
