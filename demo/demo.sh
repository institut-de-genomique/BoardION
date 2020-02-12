#!/usr/bin/env bash

# execute the script generating data for preprocess program
echo "STARTING file generation"
/usr/local/src/demo/boardionDemo_generateFile.pl /usr/local/src/demo/data /usr/local/src/demo/stat 20 50000 /usr/local/src/demo/raw/* > /usr/local/src/demo/logs/seq_sum_generation.log 2>&1 &
sleep 4

# start preprocess and webapp
/usr/local/src/docker_entrypoint.sh 600 2 80
