#!/bin/bash

bin_path=$(cd `dirname $0`; pwd)
config=`ls *.config`
nohup ${bin_path}/pipe_3ddna.sh $config &
