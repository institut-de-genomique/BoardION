# ______________________________________________________________________________________
# PLOTS

plotGlobalAxeChoice <- function(x) {

  dt = x()

  if(input$tc_groupBy == "Month") {
    dt[,DATE:=format(as.Date(STARTTIME),format="%Y-%m")]
  } else if(input$tc_groupBy == "Year") {
    dt[,DATE:=format(as.Date(STARTTIME),format="%Y")]
  } else {
    dt[,DATE:=as.Date(STARTTIME)]
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
      dt[,GROUP := as.factor(round(get(input$tc_r_xaxe)/input$tc_groupBy)*input$tc_groupBy)] # compute bin for geom_boxplot
      p <- p + geom_boxplot(aes(x=GROUP,group=GROUP))
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
  req(nrow(runInfoStatReader()>0), input$tc_r_xaxe, input$tc_r_yaxe)
  my_tooltip=''
  if(input$tc_groupBy == 0 || input$tc_groupBy == "None") {
    my_tooltip="text"
  }

  ggplotly (plotGlobalAxeChoice(runInfoStatReader), dynamicTicks = TRUE, tooltip=my_tooltip) %>% style(hoverlabel = list(bgcolor = "white")) %>% plotlyConfig() #,tooltip = "text"
})

output$tabComp_runs_xAxeChoice <- renderUI({
  req(nrow(runInfoStatReader())>0)
  colToDrop = c("STARTTIME","GROUP")
  colN = colnames(runInfoStatReader())
  colN = colN[! colN %in% colToDrop]
  selectInput(
    "tc_r_xaxe",
    "X axe",
    colN,
    selected = "#READS"
  )
})

output$tabComp_runs_yAxeChoice <- renderUI({
  req(nrow(runInfoStatReader())>0)
  colToDrop = c("FLOWCELL","STARTTIME","DATE","GROUP")
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

  if(input$tc_r_xaxe %in% c("FLOWCELL","ENDED")) {
    return()
  } else if(input$tc_r_xaxe == "DATE") {
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
