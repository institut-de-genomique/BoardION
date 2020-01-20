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

```
git clone https://github.com/institut-de-genomique/BoardION.git
cd BoardION
```

### Build and install preprocessing script

```
cd boardion_preprocess
cmake ...
...
```

This script need to be executed regurlarly to update the date display in the web interface. For exemple to execute it every 5 minutes with cron:

```
crontab -e
```

add inside:

```
*/5 * * * * boardion_preprocess -i input/dir -o output/dir
```

The input directory need to contain the sequencing_summary.txt files to monitore in the web interface and the ouput directory need to be visible by the web server.
