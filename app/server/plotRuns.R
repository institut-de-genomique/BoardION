# ______________________________________________________________________________________
# PLOTS

plotGlobalAxeChoice <- function(x) {

  dt = x()

  if(input$tc_groupBy == "Month") {
    dt[,Date:=format(as.Date(StartTime),format="%Y-%m")]
  } else if(input$tc_groupBy == "Year") {
    dt[,Date:=format(as.Date(StartTime),format="%Y")]
  } else {
    dt[,Date:=as.Date(StartTime)]
  }

  p <- ggplot(
    dt,
    aes(
      x=get(input$tc_r_xaxe),
      y=get(input$tc_r_yaxe)
    )
  ) + xlab(input$tc_r_xaxe) + ylab(input$tc_r_yaxe) + theme_bw() #+ theme(axis.text.x = element_text(angle = 60, hjust = 1))

  if(input$tc_groupBy != 0 && input$tc_groupBy != "None") {
    if(input$tc_groupBy == "Month" || input$tc_groupBy == "Year") {
      p <- p + geom_boxplot() 
    } else {
      dt[,Group := as.factor(round(get(input$tc_r_xaxe)/input$tc_groupBy)*input$tc_groupBy)] # compute bin for geom_boxplot
      p <- p + geom_boxplot(aes(x=Group,group=Group))
    } 

  } else {
    p <- p + geom_point(
			aes(
			    text=paste(
                                        input$tc_r_xaxe,': ',get(input$tc_r_xaxe),
					'<br>',input$tc_r_yaxe,': ',get(input$tc_r_yaxe),
				       	sep=''
				      )
                           )
                       )
  }
  return(p)
}

# ______________________________________________________________________________________
# RENDER

output$tabComp_runs_plot <- renderPlotly ({
  req( nrow(runInfoStatReader()>0))
  req( !is.null(input$tc_r_xaxe))
  req( !is.null(input$tc_r_yaxe))
  req( !is.null(input$tc_groupBy))
  my_tooltip=''
  if(input$tc_groupBy == 0 || input$tc_groupBy == "None") {
    my_tooltip="text"
  }

  ggplotly (plotGlobalAxeChoice(runInfoStatReader), dynamicTicks = TRUE, tooltip=my_tooltip) %>% style(hoverlabel = list(bgcolor = "white")) %>% plotlyConfig() #,tooltip = "text"
})

output$tabComp_runs_xAxeChoice <- renderUI({
  req(nrow(runInfoStatReader())>0)
  colToDrop = c("StartTime","Group")
  colN = colnames(runInfoStatReader())
  colN = colN[! colN %in% colToDrop]
  selectInput(
    "tc_r_xaxe",
    "X axe",
    colN,
    selected = "#Reads"
  )
})

output$tabComp_runs_yAxeChoice <- renderUI({
  req(nrow(runInfoStatReader())>0)
  colToDrop = c("RunID","StartTime","Date","Group")
  colN = colnames(runInfoStatReader())
  colN = colN[! colN %in% colToDrop]

  selectInput(
    "tc_r_yaxe",
    "Y axe",
    colN,
    selected = "Quality"
  )
})

output$tabComp_runs_groupByChoice <- renderUI({
  req(nrow(runInfoStatReader())>0,input$tc_r_xaxe)

  if(input$tc_r_xaxe %in% c("RunID","Ended")) {
    return()
  } else if(input$tc_r_xaxe == "Date") {
    bins = c("Year","Month","None")
    return(selectInput(
      "tc_groupBy",
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
