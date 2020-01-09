# ______________________________________________________________________________________
# PLOTS

plotGlobalAxeChoice <- function(x) {

  dt = x()

  # x_axe = x()[,get(input$xaxe)]
  # y_axe = x()[,get(input$yaxe)]

  if(input$tc_groupBy == "Month") {
    dt[,STARTTIME:=format(STARTTIME,format="%m")]
  } else if(input$tc_groupBy == "Year") {
    dt[,STARTTIME:=format(STARTTIME,format="%Y")]
  }

  # } else if(input$tabComp_runs_groupByChoice != "None") {
  #     bins = vect2bin(x_axe, lower=0, upper=max(x_axe),by=as.numeric(input$tabComp_runs_groupByChoice)) # compute bins for x
  #     dt = data.table(x=bins,yVar=y_axe)
  #     dt = dt[,y:=mean(yVar),by=x]                                                   # compute mean of the y var for each bins of x
  #     dt$x = as.numeric(as.character(dt$x))                                          # convert from factor to numeric

  # } else if(input$tabComp_runs_xAxeChoice == "STARTTIME") { # for this plot we don't need the hour:min:seconde resolution
  #     dt[,STARTTIME:=as.Date(STARTTIME)]
  # }

  # print(dt)

  p <- ggplot(
    dt,
    aes(
      x=get(input$tc_r_xaxe),
      y=get(input$tc_r_yaxe)
      # text=paste(
      #         'Flowcell: ',FLOWCELL,
      #         '<br>',input$tabComp_runs_xAxeChoice,': ',get(input$tabComp_runs_xAxeChoice),
      #         '<br>',input$tabComp_runs_yAxeChoice,': ',get(input$tabComp_runs_yAxeChoice),
      #         sep="")
    )
  ) + xlab(input$tc_r_xaxe) + ylab(input$tc_r_yaxe) + theme_bw() #+ theme(axis.text.x = element_text(angle = 60, hjust = 1))

  if(input$tc_groupBy != 0) {
    if(input$tc_groupBy == "Month" || input$tc_groupBy == "Year") {

    } else {
      p <- p + stat_summary_bin(fun.y=mean, geom="col", binwidth=as.integer(input$tc_groupBy), width=as.integer(input$tc_groupBy))
    }

  } else if(input$tabComp_runs_typePlotChoice == "scatter plot") {
    p <- p + geom_point()

  } else if(input$tabComp_runs_typePlotChoice == "bar plot") {
    width = ( max(x()[,get(input$tc_r_xaxe)]) - min(x()[,get(tc_r_xaxe)]) ) * 0.005
    p <- p + geom_col(position="stack",fill="white",col="black",width=width)

  } else if(input$tabComp_runs_typePlotChoice == "box plot") {
    p <- p + geom_boxplot()

  } else if(input$tabComp_runs_typePlotChoice == "line plot") {
    p <- p + geom_line()

  }
  return(p)
}

# ______________________________________________________________________________________
# RENDER

output$tabComp_runs_plot <- renderPlotly ({
  req(nrow(runInfoStatReader()>0), input$tc_r_xaxe, input$tc_r_yaxe)
  ggplotly (plotGlobalAxeChoice(runInfoStatReader), dynamicTicks = TRUE) %>% style(hoverlabel = list(bgcolor = "white")) %>% plotlyConfig() #,tooltip = "text"
})

output$tabComp_runs_xAxeChoice <- renderUI({
  req(nrow(runInfoStatReader())>0)
  selectInput(
    "tc_r_xaxe",
    "X axe",
    colnames(runInfoStatReader()),
    selected = "#READS"
  )
})

output$tabComp_runs_yAxeChoice <- renderUI({
  req(nrow(runInfoStatReader())>0)
  colToDrop = c("FLOWCELL","STARTTIME")
  colN = colnames(runInfoStatReader())
  colN = colN[! colN %in% colToDrop]

  selectInput(
    "tc_r_yaxe",
    "Y axe",
    colN,
    selected = "QUALITY"
  )
})

output$tabComp_runs_groupByChoice <- renderUI({
  req(nrow(runInfoStatReader())>0,input$tc_r_xaxe)

  if(input$tc_r_xaxe == "FLOWCELL") {
    return()
  } else if(input$tc_r_xaxe == "STARTTIME") {
    bins = c("Year","Month")
    return(selectInput(
      "groupBy",
      "",
      bins,
      selected="Month"
    ))
  } else {
    slider.min=0
    maxVal = max(runInfoStatReader()[,get(input$tc_r_xaxe)])
    lowestPowOf10 = 10**as.integer(log10(maxVal))
    slider.step = 0.01*lowestPowOf10
    slider.max = lowestPowOf10 + slider.step * ceiling( (maxVal - lowestPowOf10) / slider.step )

    return(sliderInput(
      "tc_groupBy",
      "Bin size",
      min = slider.min,
      max = slider.max,
      step = slider.step,
      value = 0
    ))
  }
})

# ______________________________________________________________________________________
# Click on a run of the graph to display the page of this run
#observeEvent(
#       event_data("plotly_click", source = "globalBar"),
#       {
#               d <- event_data("plotly_click", source = "globalBar")
#               updateSelectInput(
#                       session,
#                       "runList",
#                       selected = d
#               )
#               updateTabItems(
#                       session,
#                       "menu",
#                       selected = "run"
#               )
#       }
#)
