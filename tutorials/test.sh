#!/bin/bash
NODES=$(cat /etc/JARVICE/cores| wc -l)

echo $(( ${NODES}*16 ))

