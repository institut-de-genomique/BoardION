FROM centos:7

RUN yum update -y && yum install -y \
	epel-release \
	openssl-devel \
	libcurl \
	libcurl-devel \
	cairo-devel \
	libxml2-devel \
	udunits2-devel \
	cronie && \
	yum install -y R && \
	R -e 'install.packages(c("bit64","ggplot2","plotly","shiny","shinydashboard","shinyWidgets","data.table","readr","devtools","shinycssloaders","DT"),repos="https://mirror.ibcp.fr/pub/CRAN/");'

COPY ./ /usr/local/src
WORKDIR /usr/local/src

ENTRYPOINT ["/usr/local/src/docker_entrypoint.sh"]

