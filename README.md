 ---
# BoardION

BoardION is an interactive web application for real time monitoring of ONT sequencing runs. It provides the possibility for sequencing platforms to remotely monitor their ONT sequencing devices. The interactive interface of BoardION allows users to explore easily sequencing metrics in order to optimize reactively the quantity and the quality of the generated data. It also enables the comparison of multiple flowcells to assess the library preparations or the quality of samples.

## Prerequisites

You will need to have the following prerequisites fulfilled.

- gcc >=8.3
- R >= 3.6.0
- R packages:
```
install.packages(c("bit64","data.table","plotly","shinydashboard","shinycssloaders","shinyWidgets","DT"))
```

For the plotly package you may have to install first some system packages:

| deb (Debian, Ubuntu, etc) | rpm (Fedora, CentOS, RHEL) |
| ----------- | ----------- |
| libcurl4-openssl-dev | libcurl-devel |
| libssl-dev | openssl-devel |

## Installation

To install Boardion you first need to get the source code in the git repository:

```
git clone https://github.com/institut-de-genomique/BoardION.git
cd BoardION
```

Boardion is divided in 2 parts:
- the preprocessing script (in c++)
- the web application (in R)

### Install the preprocessing script

```
cd preprocess
mkdir build
cd build
cmake ../
make
make install
```

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

The server require no installation as it is in R. Just execute it (you need to precise the ip adress, the port and the input directory):

```
cd app
Rscript boardion_app.r 0.0.0.0 port input/dir
```

The input directory of the web server is the output directory of the preprocessing script.



