#!/bin/bash

[ -r /etc/JARVICE/jobinfo.sh ] && . /etc/JARVICE/jobinfo.sh
[ -r /etc/JARVICE/jobenv.sh ] && . /etc/JARVICE/jobenv.sh

source /opt/DL/tensorflow/bin/tensorflow-activate

set -x
python $@
