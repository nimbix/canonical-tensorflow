#!/bin/bash
set -e
set -x

source /opt/DL/tensorflow/bin/tensorflow-activate

export TASK_TYPE="$1"
export TASK_ID=$2

if [ ! -r /data/tutorials/config.json ]; then 
   export TF_CONFIG=$(python /usr/local/distributed-tensorflow/tutorials/gen_config.py)
else
   export TF_CONFIG=$(cat /data/config.json)
fi

echo "TF_CONFIG: $TF_CONFIG"

if [ "$TASK_TYPE" = "master" ]; then
  /data/tutorials/tensorflow.sh /usr/local/distributed-tensorflow/tutorials/simple_dist_experiment.py train_and_evaluate >> /tmp/$$.log
else
  /data/tutorials/tensorflow.sh /usr/local/distributed-tensorflow/tutorials/simple_dist_experiment.py train >> /tmp/$$.log
fi