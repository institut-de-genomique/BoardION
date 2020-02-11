#!/usr/bin/env bash

# execute the script generating data for preprocess program
echo "STARTING file generation"
/usr/home/root/demo/boardionDemo_generateFile.pl /usr/home/root/demo/data /usr/home/root/demo/stat 20 50000 /usr/home/root/demo/raw/* > /usr/home/root/demo/logs/seq_sum_generation.log 2>&1 &
sleep 4

# generate stat file before launching app
echo "FIRST PREPROCESS"
/usr/home/root/demo/boardion_preprocess -i /usr/home/root/demo/data -o /usr/home/root/demo/stat/ > /usr/home/root/demo/logs/preprocess.log 2>&1

# running every 5 minutes the preprocess program
echo "SETUP crontab"
echo "*/2 * * * * /usr/home/root/demo/boardion_preprocess -i /usr/home/root/demo/data -o /usr/home/root/demo/stat/ >> /usr/home/root/demo/logs/preprocess.log 2>&1" > /usr/home/root/demo/demo-crontab2
crontab /usr/home/root/demo/demo-crontab2

# start cron daemon
echo "STARTING cron"
crond

# execute the application
echo "STARTING app"
cd /usr/home/root/app/
Rscript boardion_app.R 80 /usr/home/root/demo/stat
