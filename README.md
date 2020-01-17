 ---
# BoardION

# Installation

## Prerequisites

You will need to have the following prerequisites fulfilled.

- gcc >=8.3
- R
- 

The web interface require R and depends on several R packages.

For the plotly package you may have to install first some system packages:

| deb (Debian, Ubuntu, etc) | rpm (Fedora, CentOS, RHEL) |
| ----------- | ----------- |
| libcurl4-openssl-dev | libcurl-devel |
| libssl-dev | openssl-devel |

```{R}
install.packages(c("bit64","plotly","shinydashboard","shinycssloaders","shinyWidgets","data.table","DT")) #"readr","devtools"
```

