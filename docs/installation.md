# Installation

A docker image containing both the preprocessing program and the web application is available at [dockerhub](https://registry.hub.docker.com/u/rdbioseq/BoardION/).

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

This program need to be executed regurlarly to update the data displayed in the web interface. For exemple, to execute it every 5 minutes with cron:

```
crontab -e
```

add inside the crontab the following line:

```
*/5 * * * * boardion_preprocess -i input/dir -o output/dir
```

Inside the input directory it will detect and parse every sequencing_summary.txt and final_summary.txt.

> Note that the ouput directory need to be visible by the web server.

## Install the web server

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
