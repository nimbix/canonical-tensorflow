#!/bin/bash

. /opt/DL/tensorflow/bin/tensorflow-activate

export TASK_TYPE="$1"
export TASK_ID=$2

if [ ! -r /data/tutorials/config.json ]; then 
   export TF_CONFIG=$(python `dirname $0`/gen_config.py)
else
   export TF_CONFIG=$(cat `dirname $0`/config.json)
fi

exec /data/tutorials/tensorflow.sh /data/tutorials/simple_dist_experiment.py train >> /tmp/$$.log

  
