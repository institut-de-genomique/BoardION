## Installation with docker

A docker image containing both the preprocessing program and the web application is available at [dockerhub](https://registry.hub.docker.com/u/rdbioseq/BoardION/).

```
docker run -it -p 80:80 -v path/to/input/folder/:/usr/local/src/data:z -v path/to/stat/folder/:/usr/local/src/stat:z boardion:latest 
```

The input folder contains the sequencing summary file and the final summary. The stat folder is intially empty and will contain the output of the preprocessing program.

The docker start by generating the stat files and then the web app start. This first step can take some time if there is a lot of data in the input folder that were not previously processed. 


## Installation from sources

To install BoardION you first need to get the source code in the git repository:

```
git clone https://github.com/institut-de-genomique/BoardION.git
cd BoardION
```

BoardION is divided in 2 programs:
- the preprocessing (in c++)
- the web application (in R)

The preprocessing program will create files containing the data displayed in the web interface. Thus this 2 programs only need to have access to the same folder and can be run on different computer.

### Install the preprocessing script

The preprocessing script require gcc>=8.3.0 and cmake>2.8 to compile.

```
cd preprocess
mkdir build
cd build
cmake -G "Unix Makefiles"  -DCMAKE_INSTALL_PREFIX=path/to/install/dir ..
cmake --build . --target install
```

This will produce in path/to/install/dir a binary named boardion_preprocess.

This script need to be executed regurlarly to update the data displayed in the web interface. For exemple, to execute it every 5 minutes with cron:

```
crontab -e
```

add inside the crontab the following line:

```
*/5 * * * * boardion_preprocess -i input/dir -o output/dir
```

Inside the input directory it will detect and parse every sequencing_summary.txt and final_summary.txt.
Note that the ouput directory need to be visible by the web server.

### Install the web server

The server require no installation as it is in R but require several R packages. Therefore an installation with docker or singularity is proposed.

To build the docker run in the app folder:
```
docker build -t boardion-app ./
```

To build with singularity:
```
singularity build boardion_app boardion.sif
```

If you prefer to run it directly on your system, here is the list of depencies:

- R (tested with R>=3.6.0)
- R packages:
```
install.packages(c("bit64","data.table","plotly","shinydashboard","shinycssloaders","shinyWidgets","DT"))
```

For the plotly package you may have to install first some system packages:

| deb (Debian, Ubuntu, etc) | rpm (Fedora, CentOS, RHEL) |
| ----------- | ----------- |
| libcurl4-openssl-dev | libcurl-devel |
| libssl-dev | openssl-devel |
