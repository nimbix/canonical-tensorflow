#!/bin/bash
set -e
set -x

export TASK_TYPE="$2"
export TASK_ID="$3"

export TF_CONFIG=$(/usr/local/distributed-tensorflow/tools/bin/generate_tensorflow_config)

echo "TF_CONFIG: $TF_CONFIG"

source /opt/DL/tensorflow/bin/tensorflow-activate

if [ "$TASK_TYPE" = "master" ]; then
  /data/tutorials/tensorflow.sh /usr/local/distributed-tensorflow/tutorials/simple_dist_experiment.py train_and_evaluate >> /tmp/$$.log
else
  /data/tutorials/tensorflow.sh /usr/local/distributed-tensorflow/tutorials/simple_dist_experiment.py train >> /tmp/$$.log
fi
