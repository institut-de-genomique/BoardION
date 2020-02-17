## Preprocessing program usage

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
   flowcell name:

        - _channel_stat.txt:   statistics per channel

        - _A_currentstat.txt:  bins read by --step-duration minutes and makes statistics independently on each bin (bin 20 independent from bin 10)

        - _A_globalstat.txt:   bins read by --step-duration minutes and makes cumulative statistics on each bin (bin 20 contain bin 10)

        - _A_quality_stat.txt: statistics binned by quality and time

        - _A_readsLength.txt:  count of reads per length
```

## Web app usage

```
Usage: ./docker_entrypoint.sh [-h] [-d <DURATION>] [-f <FREQUENCIE>] [-p <PORT>]

-d <INT> duration of a step in secondes (10 minutes == 400 values per graph for run of 4000 minutes) [600]
-f <INT> frequencie of the cron genrating stat file in minute (every <INT> minutes), it's the refresh rate of the data in the app [5]
-p <INT> port to listen [80]
```

## Usage with docker
