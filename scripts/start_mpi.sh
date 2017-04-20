#!/bin/bash

SCRIPT="$1"
GPUS_PER_NODE=4
TENSORFLOW_OUTDIR=/data/tensorflow-output

export PYTHONPATH=$PYTHONPATH:/usr/local/distributed-tensorflow/tools/lib
export PATH=$PATH:/usr/local/distributed-tensorflow/tools/bin

[ -r /etc/JARVICE/jobenv.sh ] && source /etc/JARVICE/jobenv.sh
[ -r /etc/JARVICE/jobinfo.sh ] && source /etc/JARVICE/jobinfo.sh

export JOB_NAME
export EXPERIMENT_ID
export GPUS_PER_NODE

mkdir -p ${TENSORFLOW_OUTDIR}
cd ${TENSORFLOW_OUTDIR}
tensorboard --logdir ${TENSORFLOW_OUTDIR} &

sudo service ssh start 2>/dev/null

`which mpirun` -x JOB_NAME,EXPERIMENT_ID -hostfile /etc/JARVICE/nodes --map-by ppr:${GPUS_PER_NODE}:node /usr/local/distributed-tensorflow/scripts/mpiwrapper.sh 
