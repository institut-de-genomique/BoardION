# Installation

BoardION uses the sequencing summary file produced by the basecalling to get metrics on each read. Since this file can be quite large (>10GB), the web application would be slow if it loaded and analyzed it directly. BoardION is therefore divided into two programs :
- a preprocessing program in C++
- the web application in R

## Docker

A docker image containing both the preprocessing program and the web application is available on docker hub:

```
docker pull rdbioseq/boardion
```

See this [page](usage.md#docker) for the usage.

## Prerequisites

To compile the preprocessing program:
- gcc>=8.3.0
- cmake>2.8

For running the web application:
- R (tested with R 3.6.0)
- R packages:
    - bit64
    - data.table
    - plotly
    - shinydashboard
    - shinycssloaders
    - shinyWidgets
    - DT

## Install the preprocessing script

First clone the git repository:

```
git clone https://github.com/institut-de-genomique/BoardION.git
cd BoardION
```

Compile the preprocessing program ( use '-DCMAKE_INSTALL_PREFIX=' to set the installation path of the binary)

```
cd preprocess
mkdir build
cd build
cmake -G "Unix Makefiles"  -DCMAKE_INSTALL_PREFIX=path/to/install/dir ..
cmake --build . --target install
```

This program needs to be executed regularly to update the data displayed in the web interface. For exemple, to execute it every 5 minutes with cron:

```
crontab -e
```

add inside the crontab the following line:

```
*/5 * * * * boardion_preprocess -i input/dir -o output/dir
```
See [here](usage.md#preprocessing-program) for the complete list of options.

Inside the input directory it will detect and parse every sequencing_summary.txt and final_summary.txt. 

> Note that the ouput directory needs to be visible by the web server.

## Install the web server

The server requires no installation as it is in R but requires several R packages. Therefore an installation with docker or singularity is proposed.

To build the docker in the app folder:
```
docker build -t boardion-app ./
```

To build with singularity:
```
singularity build boardion_app boardion.sif
```

If you prefer to run it directly on your system, here is the list of dependencies:

- R (tested with R>=3.6.0)
- R packages:
```
install.packages(c("bit64","data.table","plotly","shinydashboard","shinycssloaders","shinyWidgets","DT"))
```
