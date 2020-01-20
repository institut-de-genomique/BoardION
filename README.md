 ---
# BoardION

## Prerequisites

You will need to have the following prerequisites fulfilled.

- gcc >=8.3
- R
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

### Install and configure the preprocessing script

```
cd boardion_preprocess
cmake ...
...
```

This script need to be executed regurlarly to update the data displayed in the web interface. For exemple, to execute it every 5 minutes with cron:

```
crontab -e
```

add inside:

```
*/5 * * * * boardion_preprocess -i input/dir -o output/dir
```

Inside the input directory it will detect and parse every sequencing_summary.txt and final_summary.txt. 
Note that the ouput directory need to be visible by the web server.

### Install the web server



