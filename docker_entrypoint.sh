#!/usr/bin/env bash

usage() {

	echo "
Usage: $0 [-h] [-d <DURATION>] [-f <FREQUENCY>] [-p <PORT>] (-R <REGEX>]

-d <INT> duration of a step in secondes (10 minutes == 400 values per graph for run of 4000 minutes) [600]
-f <INT> frequency of the cron genrating stat file in minute (every <INT> minutes), it's the refresh rate of the data in the app [5]
-p <INT> port to listen [80]
-R <STR> Regular expression to get uniq run id from sequencing summary file name. If not present, run id is the concatenation of the flowcell id and the first 8 characters of the run_id field of the sequencing summary.
" 1>&2

	exit 1
}

DURATION=600
FREQUENCY=5
PORT=80
REGEX=""

while getopts "hd:f:p:R:" opts; do
	case ${opts} in
		d) DURATION=${OPTARG} ;;
		f) FREQUENCY=${OPTARG} ;;
		p) PORT=${OPTARG} ;;
		R) REGEX=${OPTARG};;
		h) usage;;
		:) usage;;
		?) usage;;
	esac
done

shift $((OPTIND-1))

# generate stat file before launching the app, because the app crash if input folder empty
echo "generating intial stat files..."
if [[ ! -z "$REGEX" ]]
then
	REGEX="-R ${REGEX}"
fi
/usr/local/src/boardion_preprocess -d ${DURATION} ${REGEX} -i /usr/local/src/data -o /usr/local/src/stat/ > /usr/local/src/logs/preprocess.log 2>&1

# running every X minutes the preprocess program
echo "setup crontab..."
echo "*/${FREQUENCY} * * * * /usr/local/src/boardion_preprocess -d ${DURATION} ${REGEX} -i /usr/local/src/data -o /usr/local/src/stat/ >> /usr/local/src/logs/preprocess.log 2>&1" > /usr/local/src/boardion-crontab
crontab /usr/local/src/boardion-crontab

# start cron daemon
echo "start cron..."
crond

# execute the application
echo "start app..."
cd /usr/local/src/app/
Rscript boardion_app.R ${PORT} /usr/local/src/stat
