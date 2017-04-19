#!/bin/bash

GPUS_PER_NODE=4

`which mpirun` -hostfile /etc/JARVICE/nodes --map-by ppr:${GPUS_PER_NODE}:node /bin/bash `dirname $0`/mpiwrapper.sh 
