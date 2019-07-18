# ______________________________________________________________________________________
# FILES READERS

runInfoStatReader <- reactive ({
	data <- reactiveFileReader(
		intervalMillis = 60000,
		session	       = NULL,
		filePath       = paste(reportingFolder,"/run_infostat.txt",sep=""),
		readFunc       = readCsvSpace2
	)()

	data[,STARTTIME := as.POSIXct(STARTTIME,format="%Y-%m-%dT%H:%M:%S")]

})

# ______________________________________________________________________________________
# PLOTS

plotGlobalAxeChoice <- function(x) {
	dt = x()
	
#	dt[,STARTTIME := as.Date(STARTTIME)]
	
	ggplot( 
		dt,
		aes( x=get(input$xaxe), y=get(input$yaxe), text=paste(input$xaxe,': ',get(input$xaxe),'<br>',input$yaxe,': ',get(input$yaxe),sep=""))
	) +
	geom_point() +
	xlab(input$xaxe) +
	ylab(input$yaxe) +
	theme_bw() +
	theme(axis.text.x = element_text(angle = 60, hjust = 1))
}

# ______________________________________________________________________________________
# RENDER

output$nbReadRun <- renderPlotly({
	#plotGlobalNbRead(runInfoStatReader())
	plot_ly(runInfoStatReader(), x= ~get("FLOWCELL"), y=~get("YIELD(b)"), type= "bar", source = "globalBar") %>% 
	layout(xaxis = list(title="Flowcell"), yaxis = list(title="Yield (bases)")) %>% 
	plotlyConfig()
})

output$axeChoice <- renderPlotly ({
	req(nrow(runInfoStatReader()>0),input$xaxe,input$yaxe)
	ggplotly (plotGlobalAxeChoice(runInfoStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
})

output$xAxeChoice <- renderUI({
	selectInput(
		"xaxe",
		"X axe",
		colnames(runInfoStatReader())
	)
})

output$yAxeChoice <- renderUI({
	colToDrop = c("FLOWCELL")
	colN = runInfoStatReader()[,!..colToDrop]
	
	selectInput(
		"yaxe",
		"Y axe",
		colnames(colN)
	)
})
	
output$vb_nbRunInProgress <- renderInfoBox({
	print("TEST")
	print(input$runList)
	nb_runInProgress = length(runInfoStatReader()[ENDED=="NO",FLOWCELL])
	valueBox(
		nb_runInProgress,
		"Run in progress",
		icon = icon("cogs")
	)
})


# ______________________________________________________________________________________
# Click on a run of the graph to display the page of this run
observeEvent(
	event_data("plotly_click", source = "globalBar"),
	{
		d <- event_data("plotly_click", source = "globalBar")
		updateSelectInput(
			session,
			"runList",
			selected = d
		)
		updateTabItems(
			session,
			"menu",
			selected = "run"
		)
	}
)
