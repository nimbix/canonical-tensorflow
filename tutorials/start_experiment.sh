#!/bin/bash


set -x

# Explicitly set CUDA_VISIBLE_DEVICES because otherwise each Tensorflow process allocates all of the GPU memory available
# sleeps are necessary...because Tensorflow does not deal well with uncertainty in the environment....even when it is told
# what to expect via TF_CONFIG

# The architecture that I *think* would be most sensible on Nimbix for a general architecture is the following:
# Given N as the number of GPUs
# 1 PS -> 1 GPU
# N-1 WORKERS -> 1 GPU EACH (specified via CUDA visible devices)
# 1 MASTER -> 0 GPUs (i.e., CPU only)

export CUDA_VISIBLE_DEVICES=0
# start_wrapper sets the TF_CONFIG and then starts an appropriate process
/data/tutorials/start_wrapper.sh ps 0 2>/tmp/ps.log &

sleep 5

export CUDA_VISIBLE_DEVICES=1
/data/tutorials/start_wrapper.sh worker 0 2>/tmp/primaryworker.log &

sleep 5


#ssh $(hostname) "nohup /data/tutorials/start_wrapper.sh worker 0 >>/tmp/\$\$.log &"
#if [ `cat /etc/JARVICE/nodes | wc -l` -gt 1 ]; then
#	ssh $(tail -n1 /etc/JARVICE/nodes) "export CUDA_VISIBLE_DEVICES=0,1; nohup /data/tutorials/start_wrapper.sh ps 1 &"
#	ssh $(tail -n1 /etc/JARVICE/nodes) "export CUDA_VISIBLE_DEVICES=2,3; nohup /data/tutorials/start_wrapper.sh worker 1 &"
#fi

export CUDA_VISIBLE_DEVICES=3
/data/tutorials/start_wrapper.sh master 0 2>/tmp/master.log


