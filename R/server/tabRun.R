# ______________________________________________________________________________________
# FILES READERS

globalStatReader <- reactive ({
	reactiveFileReader(
		intervalMillis = 60000,
		session	       = NULL,
		filePath       = paste(reportingFolder,"/",input$runList,"_globalstat.txt",sep=""),
		readFunc       = readCsvSpace2
	)()
})

currentStatReader <- reactive ({
	reactiveFileReader(
		intervalMillis = 60000,
		session	       = NULL,
		filePath       = paste(reportingFolder,"/",input$runList,"_currentstat.txt",sep=""),
		readFunc       = readCsvSpace2
	)()
})

# ______________________________________________________________________________________
# PLOTS

plotRunNbBase <- function(x,startTime) {
	#plot_ly(x(), x = ~DURATION.mn., y = ~YIELD.b., type="bar") %>% plotlyConfig()
	#plot_ly(x, x = ~DURATION.mn., y = ~YIELD.b., type="scatter") %>% plotlyConfig()

	
	ggplot( x(),
		aes(x=startTime + get("DURATION(mn)") * 60,
		    y=get("YIELD(b)"),
		    fill=QUALITY,
		    text=paste('DURATION (mn): ',get("DURATION(mn)"),
			       '<br>NB READS : ',format(get("YIELD(b)"), big.mark=' '),
			       '<br>QUALITY: ',QUALITY,
			       sep=""
			      )
		)
	) +
	
	geom_col(position="dodge", width = 600) +
	
	theme_bw() +
#	theme(text = element_text(size=20)) +
	scale_fill_gradientn(colors=rainbow(5),values=c(0,.5,.6,.7,1) ,limits=c(0,15)) +
	xlab("Duration(mn)") +
	ylab("Yield (bases)") +
	labs(fill='Quality')
}

plotRunNbRead <- function(x) {


	ggplot( x(),
		aes(x=get("DURATION(mn)"),
		    y=get("#READS"),
		    fill=QUALITY,
		    text=paste('DURATION (mn): ',get("DURATION(mn)"),
			       '<br>NB READS : ',format(get("#READS"), big.mark=' '),
			       '<br>QUALITY: ',QUALITY,
			       sep=""
			      )
		)
	) +
	
	geom_col(position="dodge", width = 10) +
	
	theme_bw() +
	scale_fill_gradientn(colors=rainbow(5),values=c(0,.5,.6,.7,1) ,limits=c(0,15)) +
	xlab("Duration(mn)") +
	ylab("Number of reads") +
	labs(fill='Quality')
}

plotRunSpeed <- function(x) {
	ggplot( x(),
		aes(x=get("DURATION(mn)"),
		    y=get("SPEED(b/mn)"),
		    fill=QUALITY,
		    text=paste('DURATION (mn): ',get("DURATION(mn)"),
			       '<br>SPEED (b/mn): ',get("SPEED(b/mn)"),
			       '<br>QUALITY: ',QUALITY,
			       sep=""
			      )
		)
	) +
	
	geom_col(position="dodge", width = 10) +
	
	theme_bw() +
	scale_fill_gradientn(colors=rainbow(5),values=c(0,.5,.6,.7,1) ,limits=c(0,15)) +
	xlab("Duration(mn)") +
	ylab("Speed (bases/min)") +
	labs(fill='Quality')
}


# ______________________________________________________________________________________
# RENDER

output$runTitle <- renderText({
	req(input$runList != "")
	state = ""
	state = runInfoStatReader()[FLOWCELL==input$runList,ENDED]
	
	if(state == "YES") {
		state = "COMPLETED"
	} else if(state == "NO") {
		state = "IN PROGRESS"
	}
	paste(input$runList," - ",state,sep="")
})

output$plot_globalRunNbBase <- renderPlotly({
#output$plot_globalRunNbBase <- renderPlot({
	if(nrow(globalStatReader())) {
		startTime = as.POSIXlt(runInfoStatReader()[FLOWCELL==input$runList,STARTTIME],format="%Y-%m-%dT%H:%M:%S")
		#ggplotly(plotRunNbBase(globalStatReader,startTime), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
		ggplotly(plotRunNbBase(globalStatReader,startTime), tooltip = "text") %>% plotlyConfig()
	}
})

output$plot_globalRunNbRead <- renderPlotly({
	if(nrow(globalStatReader())) {
		ggplotly(plotRunNbRead(globalStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
	}
})

output$plot_globalRunSpeed <- renderPlotly({
	if(nrow(globalStatReader())) {
		ggplotly(plotRunSpeed(globalStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
	}
})

output$plot_currentRunNbBase <- renderPlotly({
	if(nrow(currentStatReader())) {
		ggplotly(plotRunNbBase(currentStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
	}
})

output$plot_currentRunNbRead <- renderPlotly({
	if(nrow(currentStatReader())) {
		ggplotly(plotRunNbRead(currentStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
	}
})

output$plot_currentRunSpeed <- renderPlotly({
	if(nrow(currentStatReader())) {
		ggplotly(plotRunSpeed(currentStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
	}
})

output$runTable = renderTable(
	{runInfoStatReader()[FLOWCELL==input$runList]},
	bordered = TRUE
)

# ______________________________________________________________________________________
# 

# update drop-down list of run
observe({

	runSelected = isolate(input$runList) # save the selected before the update of the list
	listRun = list()
	
	if(is.null(runInfoStatReader()) | nrow(runInfoStatReader())==0) {
		listRun <- character(0)
		runSelected = NULL
		
	} else {
		listRun = list(
			"In progress" = c("",runInfoStatReader()[ENDED=="NO",FLOWCELL]), # add an empty slot, else the list doen not display correctly
			"Completed" = c(runInfoStatReader()[ENDED=="YES",FLOWCELL])
		)

		if (runSelected == "") {
			runSelected = runInfoStatReader()[STARTTIME==max(STARTTIME),FLOWCELL] # if there isn't a run selected, take the most recent
		}
	}
	
	updateSelectInput( 
		session,
		"runList",
		choice = listRun,
		selected = runSelected # use the selected run before the update, so that if runInfoStatReader() update the ui does not display the default run but the last one selected by the user
	)
})
