# BoardION web interface

BoardION's interface is composed of 3 pages:
- Runs in progress: displays runs that are currently sequenced
- Sequencing overview: shows final metrics of all run and allows you to compare them
- Run: more informations and plots on a selected run

## Plots

All the graphs are made with plotly and are therefore dynamic. To allow you to explore the data without the graph refreshing every few minutes, graphs in the sequencing overview page and run page are not refresh automatically. Instead there is a button next to each graph to refresh the data and the selection of axes.

## Runs in progress view

This page show for each run currently sequenced 2 graphs:
- the yield over time
- the read length distribution

Each run is displayed in a separate box which can be expended/reduced using the '+'/'-' in the top right corner.

> the more boxes you open, the longer it'll take to refresh the data, as there is more graph to draw.

![runs in progress tab](images/tabRunInProgress.png)

Between the table and the first run, there is a toggle button. This button is used for switch between cumulative and non-cumualative mode for the yield graph.

![runs in progress tab](images/tabRunInProgress_toggle.png)


## Sequencing overview

This page is divided in 2 parts, the overview the run comparison.

### Overview

![overview tab](images/tabOverview.png)

### Run comparison



## Run view

![runs tab](images/tabRun.png)
