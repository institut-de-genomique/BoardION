#!/usr/bin/env bash

# execute the script generating data for preprocess program
echo "starting file generation"
/usr/local/src/demo/boardionDemo_generateFile.pl /usr/local/src/data /usr/local/src/stat 20 50000 /usr/local/src/raw/* > /usr/local/src/logs/seq_sum_generation.log 2>&1 &
sleep 4

# start preprocess and webapp
/usr/local/src/docker_entrypoint.sh -d 600 -f 2 -p 80
