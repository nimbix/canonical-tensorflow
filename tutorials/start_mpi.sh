#!/bin/bash

export PYTHONPATH=$PYTHONPATH:/usr/local/tensorflowtools

[ -r /etc/JARVICE/jobenv.sh ] && source /etc/JARVICE/jobenv.sh
[ -r /etc/JARVICE/jobinfo.sh ] && source /etc/JARVICE/jobinfo.sh

GPUS_PER_NODE=4

`which mpirun` -x JOB_NAME,EXPERIMENT_ID -hostfile /etc/JARVICE/nodes --map-by ppr:${GPUS_PER_NODE}:node /bin/bash `dirname $0`/mpiwrapper.sh 
