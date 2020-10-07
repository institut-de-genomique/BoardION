# ______________________________________________________________________________________
# PLOTS

plotGlobalAxeChoice <- function(dt, groupBy, xAxe, yAxe) {

  if(groupBy == "Month") {
    dt[,Date:=format(as.Date(StartTime),format="%Y-%m")]
  } else if(groupBy == "Year") {
    dt[,Date:=format(as.Date(StartTime),format="%Y")]
  } else {
    dt[,Date:=as.Date(StartTime)]
  }

  p <- ggplot(
    dt,
    aes(
      x=get(xAxe),
      y=get(yAxe)
    )
  ) + xlab(xAxe) + ylab(yAxe) + theme_bw() #+ theme(axis.text.x = element_text(angle = 60, hjust = 1))

  if(groupBy != 0 && groupBy != "None") {
    if(groupBy == "Month" || groupBy == "Year") {
      p <- p + geom_boxplot() 
    } else {
      dt[,Group := as.factor(round(get(xAxe)/groupBy)*groupBy)] # compute bin for geom_boxplot
      p <- p + geom_boxplot(aes(x=Group,group=Group))
    } 

  } else {
    p <- p + geom_point(
			aes(
			    text=paste(
                                        xAxe,': ',get(xAxe),
					'<br>',yAxe,': ',get(yAxe),
				       	sep=''
				      )
                           )
                       )
  }
  return(p)
}

# ______________________________________________________________________________________
# RENDER

# the plot is updated when the groupBy ui object change
output$tabComp_runs_plot <- renderPlotly ({
  req( !is.null(input$tc_groupBy) )
  input$ab_owr_refreshRuns

  isolate({

    req( nrow(runInfoStatReader())>0)
    req( !is.null(input$tc_r_xaxe))
    req( !is.null(input$tc_r_yaxe))

    my_tooltip=''
    my_dynamicTicks=FALSE
    if(input$tc_groupBy == 0 || input$tc_groupBy == "None") {
      my_tooltip="text"
      my_dynamicTicks=TRUE
    }

    g <- ggplotly ( plotGlobalAxeChoice(runInfoStatReader(), input$tc_groupBy, input$tc_r_xaxe, input$tc_r_yaxe), dynamicTicks = my_dynamicTicks, tooltip=my_tooltip) %>%
         style(hoverlabel = list(bgcolor = "white")) %>%
         plotlyConfig()
  
  })
  return(g)

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

# updated when the button refresh is clicked
output$tabComp_runs_groupByChoice <- renderUI({
  input$ab_owr_refreshRuns
  isolate({
    req(nrow(runInfoStatReader())>0)
 
   # on startup input$tc_r_axe is build after this ui, so with just a basic req this ui element is not displayed on startup
   if(input$ab_owr_refreshRuns == 0 && is.null(input$tc_r_xaxe)) { 
   	xCol = "#Reads"
   } else {
	req( !is.null(input$tc_r_xaxe))
	xCol = input$tc_r_xaxe
   }



    if(xCol %in% c("RunID","Ended")) {
      return()
    } else if(xCol == "Date") {
      bins = c("Year","Month","None")
      return(selectInput(
        "tc_groupBy",
        "",
        bins,
        selected="Month"
      ))
    } else {
      slider.min=0
      maxVal = max(runInfoStatReader()[,get(xCol)])
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
