#!/bin/bash

NNODES=$(cat /etc/JARVICE/nodes)
let NPROCS=4

`which mpirun` -np ${NPROCS} /bin/bash `dirname $0`/mpiwrapper.sh 

