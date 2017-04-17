#!/bin/bash

set -x

# One CUDA device per worker
if [ ${OMPI_COMM_WORLD_LOCAL_RANK} -lt 4 ]; then
  export CUDA_VISIBLE_DEVICES=${OMPI_COMM_WORLD_LOCAL_RANK}
  TASK_TYPE="worker"
  TASK_ID=${OMPI_COMM_WORLD_LOCAL_RANK}
elif [ ${OMPI_COMM_WORLD_LOCAL_RANK} -eq 4 ]; then
  export CUDA_VISIBLE_DEVICES=""
  TASK_ID=$(( ${OMPI_COMM_WORLD_RANK} / 5 ))
  TASK_TYPE="ps"
  if [ $TASK_ID -eq 0 ]; then
    TASK_TYPE="master"
  fi
fi

echo "Task ID[$(hostname)]: ${OMPI_COMM_WORLD_LOCAL_RANK} / ${OMPI_COMM_WORLD_RANK}"

export TASK_TYPE
export TASK_ID
export TF_CONFIG=$(python gen_config.py)
if [ "$TASK_TYPE" = "worker" ]; then
  sleep 5
fi

if [ "$TASK_TYPE" = "ps" ]; then
  sleep 3
fi
  
# Learn runner will read the TF_CONFIG object
exec /data/tutorials/tensorflow.sh $@ >/dev/null

