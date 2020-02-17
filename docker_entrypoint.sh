#!/usr/bin/env bash

usage() {

	echo "
Usage: $0 [-h] [-d <DURATION>] [-f <FREQUENCIE>] [-p <PORT>]

-d <INT> duration of a step in secondes (10 minutes == 400 values per graph for run of 4000 minutes) [600]
-f <INT> frequencie of the cron genrating stat file in minute (every <INT> minutes), it's the refresh rate of the data in the app [5]
-p <INT> port to listen [80]
" 1>&2

	exit 1
}

DURATION=600
FREQUENCIE=5
PORT=80

while getopts "hd:f:p:" opts; do
	case ${opts} in
		d) DURATION=${OPTARG} ;;
		f) FREQUENCIE=${OPTARG} ;;
		p) PORT=${OPTARG} ;;
		h) usage;;
		:) usage;;
		?) usage;;
	esac
done

shift $((OPTIND-1))

# generate stat file before launching the app, because the app crash if input folder empty
echo "generating intial stat files..."
/usr/local/src/boardion_preprocess -d ${DURATION} -i /usr/local/src/data -o /usr/local/src/stat/ > /usr/local/src/logs/preprocess.log 2>&1

# running every X minutes the preprocess program
echo "setup crontab..."
echo "*/${FREQUENCIE} * * * * /usr/local/src/boardion_preprocess -d ${DURATION} -i /usr/local/src/data -o /usr/local/src/stat/ >> /usr/local/src/logs/preprocess.log 2>&1" > /usr/local/src/boardion-crontab
crontab /usr/local/src/boardion-crontab

# start cron daemon
echo "start cron..."
crond

# execute the application
echo "start app..."
cd /usr/local/src/app/
Rscript boardion_app.R ${PORT} /usr/local/src/stat
