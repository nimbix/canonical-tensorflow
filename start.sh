#!/bin/bash

# Total number of GPUs across the entire distributed training system
GPU_COUNT=8
SCRIPT="mnist_replica.py"

# Two parameter servers per node
# Parameter servers utilize a single CPU per PS

# Two worker nodes per node
# Worker servers are the main compute work horses for the computations

PS_HOSTS=
for i in $(cat /etc/JARVICE/nodes | awk 'BEGIN { FS=" " }{ print $1:2222 }'); do
    if [ ! -z "${PS_HOSTS}" ]; then
        PS_HOSTS="${PS_HOSTS},$i"
    else
        PS_HOSTS="$i"
    fi
done
            
WORKER_HOSTS

for i in $(cat /etc/JARVICE/nodes | awk 'BEGIN {FS=" " }{ print $1:2223 }'); do
    if [ ! -z "${WORKER_HOSTS}" ]; then
        WORKER_HOSTS="${WORKER_HOSTS},$i"
    else
        WORKER_HOSTS="$i"
    fi
done


index=0
for i in `cat /etc/JARVICE/nodes`; do
    # Start a parameter server
    ssh $i "/data/tensorflow.sh ${SCRIPT} \
     --ps_hosts=${PS_HOSTS} \
     --worker_hosts=${WORKER_HOSTS} \
     --job_name=ps --task_index=${index} &"
    ssh $i "/data/tensorflow.sh ${SCRIPT} \
     --ps_hosts=${PS_HOSTS} \
     --worker_hosts=${WORKER_HOSTS} \
     --job_name=worker --task_index=${index} &"
    let index=${index}+1
done


# #python mnist_replica.py --job_name ps --worker_hosts localhost:2223 --num_gpus ${GPU_COUNT}
# # On ps0.example.com:
# python trainer.py \
#      --ps_hosts=ps0.example.com:2222,ps1.example.com:2222 \
#      --worker_hosts=worker0.example.com:2222,worker1.example.com:2222 \
#      --job_name=ps --task_index=0
# # On ps1.example.com:
# python trainer.py \
#      --ps_hosts=ps0.example.com:2222,ps1.example.com:2222 \
#      --worker_hosts=worker0.example.com:2222,worker1.example.com:2222 \
#      --job_name=ps --task_index=1
# # On worker0.example.com:
# python trainer.py \
#      --ps_hosts=ps0.example.com:2222,ps1.example.com:2222 \
#      --worker_hosts=worker0.example.com:2222,worker1.example.com:2222 \
#      --job_name=worker --task_index=0
# # On worker1.example.com:
# python trainer.py \
#     --ps_hosts=ps0.example.com:2222,ps1.example.com:2222 \
#      --worker_hosts=worker0.example.com:2222,worker1.example.com:2222 \
#      --job_name=worker --task_index=1
