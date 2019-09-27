FROM centos:7

RUN yum update -y && yum install -y \
	epel-release \
	openssl-devel \
	libcurl \
	libcurl-devel \
	cairo-devel \
	libxml2-devel \
	udunits2-devel && \
	yum install -y R && \
	R -e 'install.packages(c("bit64","ggplot2","plotly","shiny","shinydashboard","data.table","readr","devtools","shinycssloaders","DT"),repos="https://mirror.ibcp.fr/pub/CRAN/");'
COPY ./R /usr/local/src
WORKDIR /usr/local/src/
ENTRYPOINT Rscript app.R
