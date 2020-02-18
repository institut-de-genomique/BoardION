# Usage

## Docker

The docker image containing the preprocessing program and the web app is available [here](https://registry.hub.docker.com/u/rdbioseq/BoardION/).

This image need to have access to 2 folders, the first one contains the input datas (sequencing summary file and final summary) and the second one is intially empty and will contain the output of the preprocessing program.

```
docker run -it -p 80:80 -v input/folder/:/usr/local/src/data:z -v stat/folder/:/usr/local/src/stat:z boardion:latest -d 600 -f 5 -p 80
```

Here are the options you can set for the docker entrypoint:

```
Usage: ./docker_entrypoint.sh [-h] [-d <DURATION>] [-f <FREQUENCY>] [-p <PORT>]

-d <INT> duration of a step in secondes ( 600 secondes == 10 minutes == 400 values per graph for run of 4000 minutes) [600]
-f <INT> frequency of the cron runnig the preprocessing in minute (every <INT> minutes), it's the refresh rate of the data in the app [5]
-p <INT> port to listen [80]
```

> The docker start by generating the stat files and then the web app start. This first step can take some time if there is a lot of data in the input folder that were not previously processed (thus the availibilty of the web app can be delayed)


## Preprocessing program

```
USAGE:
   boardion_preprocess  [-R <REGEX>] [-d <DURATION>] [-r <RUN ID>] -o <DIRECTORY> -i <DIRECTORY> [--] [--version] [-h]

Where:
   -R <REGEX>,  --regex <REGEX>
     Regular expression to get uniq run id from sequencing summary file name. If not present, run id is the concatenation of the flowcell id and the first 8 characters of the run_id field of the sequencing summary

   -d <DURATION>,  --step-duration <DURATION>
     Duration between stats points in seconds

   -r <RUN ID>,  --runId <RUN ID>
     Run id to monitor. If not present, monitor all runs

   -o <DIRECTORY>,  --out <DIRECTORY>
     (required)  Path to the output directory

   -i <DIRECTORY>,  --in <DIRECTORY>
     (required)  Directory containing sequencing_summary.txt files to process

   --,  --ignore_rest
     Ignores the rest of the labeled arguments following this flag.

   --version
     Displays version information and exits.

   -h,  --help
     Displays usage information and exits.

   This program generates statistics files from sequencing_summary.txt files.
   It creates and uses the file run_infostat.txt that contains one line per run processed. This file contains global statistics on each run and also marks completed run that no longer need to be processed.

   For each sequencing_summary file it produces 5 files prefixed with the
   run name:

        - _channel_stat.txt:   statistics per channel

        - _A_currentstat.txt:  statistics on read binned by --step-duration minutes. Bins are independent of each other (the 10th is independent from the 9th).

        - _A_globalstat.txt:   statistics on read binned by --step-duration minutes. Later bin contains previous one. (the 10th contain the 9th)

        - _A_quality_stat.txt: statistics binned by quality and time

        - _A_readsLength.txt:  count of reads per length
```

## Web app

```
Rscript boardion_app.R [<IP>] <PORT> <INPUT_FOLDER>

<IP>           Ip of the host. By default the script try to get it with 'hostname -i'. 
<PORT>         Port to listen
<INPUT_FOLDER> Input folder containing the output of the preprocessing programm.

```
