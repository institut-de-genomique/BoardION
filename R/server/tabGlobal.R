# ______________________________________________________________________________________
# FILES READERS

<<<<<<< R/server/tabGlobal.R
readRunInfoStat <- function(file) {
	data = readCsvSpace(file)
	data[, c("LASTREADPOSITION","LASTSTEPSTARTPOSITION"):=NULL]
}
=======
#runInfoStatReader <- reactive ({
#	data <- reactiveFileReader(
#		intervalMillis = 60000,
#		session	       = NULL,
#		filePath       = paste(reportingFolder,"/run_infostat.txt",sep=""),
#		readFunc       = readCsvSpace
#	)()
#	data[,STARTTIME := as.POSIXct(STARTTIME,format="%Y-%m-%dT%H:%M:%S")]
#	return(data)
#})

>>>>>>> R/server/tabGlobal.R

runInfoStatReader<-reactiveFileReader(
       	intervalMillis = 6000,
       	session        = NULL,
       	filePath       = paste(reportingFolder,"/run_infostat.txt",sep=""),
<<<<<<< R/server/tabGlobal.R
       	readFunc       = readRunInfoStat
)


# ______________________________________________________________________________________
# RUN LISTS

rv <- reactiveValues(	updateRunList = FALSE, # flags to update the lists
			updateRipList = FALSE)

ripList <- reactive({ # run in progress
	rv$updateRipList
	isolate(runInfoStatReader()[ENDED=="NO",FLOWCELL])
})

runList <- reactive({
	rv$updateRunList
	isolate(runInfoStatReader()[,FLOWCELL])
})

observe ({ # update list of run and list of run in progress only if the coresponding list in the input file (runInfoStatReader) change and not if any value of this file change
	if(length(runInfoStatReader()[,FLOWCELL])==length(isolate(runList())) && all(runInfoStatReader()[,FLOWCELL]==isolate(runList()))) {
		isolate({
			rv$updateRunList <- TRUE
			rv$updateRunList <- FALSE
		})
	}
	
	if(length(runInfoStatReader()[ENDED=="NO",FLOWCELL])==length(isolate(ripList())) && all(runInfoStatReader()[ENDED=="NO",FLOWCELL]==isolate(ripList()))) {
		isolate({
			rv$updateRipList <- TRUE
			rv$updateRipList <- FALSE
		})
	}
=======
       	readFunc       = fread
)


rip <- reactive({ # run in progress
	runInfoStatReader()[ENDED=="NO",FLOWCELL]
>>>>>>> R/server/tabGlobal.R
})



# ______________________________________________________________________________________
# PLOTS

plotGlobalAxeChoice <- function(x) {

	dt = x()

	# x_axe = x()[,get(input$xaxe)]
	# y_axe = x()[,get(input$yaxe)]

	if(input$groupBy == "Month") {
		dt[,STARTTIME:=format(STARTTIME,format="%m")]
	} else if(input$groupBy == "Year") {
		dt[,STARTTIME:=format(STARTTIME,format="%Y")]
	}

	# } else if(input$groupBy != "None") {
	# 	bins = vect2bin(x_axe, lower=0, upper=max(x_axe),by=as.numeric(input$groupBy)) # compute bins for x
	# 	dt = data.table(x=bins,yVar=y_axe)
	# 	dt = dt[,y:=mean(yVar),by=x]                                                   # compute mean of the y var for each bins of x
	# 	dt$x = as.numeric(as.character(dt$x))                                          # convert from factor to numeric

	# } else if(input$xaxe == "STARTTIME") { # for this plot we don't need the hour:min:seconde resolution
	# 	dt[,STARTTIME:=as.Date(STARTTIME)]
	# }
	
	# print(dt)

	p <- ggplot(
		dt,
		aes(
			x=get(input$xaxe),
			y=get(input$yaxe)
			# text=paste(
			# 	'Flowcell: ',FLOWCELL,
			# 	'<br>',input$xaxe,': ',get(input$xaxe),
			# 	'<br>',input$yaxe,': ',get(input$yaxe),
			# 	sep="")
		)
	) + xlab(input$xaxe) + ylab(input$yaxe) + theme_bw() #+ theme(axis.text.x = element_text(angle = 60, hjust = 1))

	if(input$groupBy != 0) {
		if(input$groupBy == "Month" || input$groupBy == "Year") {

		} else {
			p <- p + stat_summary_bin(fun.y=mean, geom="col", binwidth=as.integer(input$groupBy), width=as.integer(input$groupBy))
		}

	} else if(input$typePlotChoice == "scatter plot") {
		p <- p + geom_point()

	} else if(input$typePlotChoice == "bar plot") {
		width = ( max(x()[,get(input$xaxe)]) - min(x()[,get(input$xaxe)]) ) * 0.005
		p <- p + geom_col(position="stack",fill="white",col="black",width=width)

	} else if(input$typePlotChoice == "box plot") {
		p <- p + geom_boxplot()

	} else if(input$typePlotChoice == "line plot") {
		p <- p + geom_line()

	}
	return(p)
}

# ______________________________________________________________________________________
# RENDER

output$nbReadRun <- renderPlotly({
	req(nrow(runInfoStatReader())>0)
	#plotGlobalNbRead(runInfoStatReader())

<<<<<<< R/server/tabGlobal.R
	ggplotly ( ggplot(runInfoStatReader(),aes(x=get("FLOWCELL"), y=get("YIELD(b)"))) + geom_col() ) + theme_bw() + theme(axis.text.x = element_text(angle = 90)) %>%

#	plot_ly(runInfoStatReader(), x= ~get("FLOWCELL"), y=~get("YIELD(b)")) %>% #, type= "bar")  , source = "globalBar") %>% 
#	layout(xaxis = list(title="Flowcell"), yaxis = list(title="Yield (bases)")) %>% 

=======
	ggplotly ( ggplot(runInfoStatReader(),aes(x=get("FLOWCELL"), y=get("YIELD(b)"))) + geom_col() ) %>%

#	plot_ly(runInfoStatReader(), x= ~get("FLOWCELL"), y=~get("YIELD(b)")) %>% #, type= "bar")  , source = "globalBar") %>% 
#	layout(xaxis = list(title="Flowcell"), yaxis = list(title="Yield (bases)")) %>% 
>>>>>>> R/server/tabGlobal.R
	plotlyConfig()
})

output$axeChoice <- renderPlotly ({
	req(nrow(runInfoStatReader()>0),input$xaxe,input$yaxe)
	ggplotly (plotGlobalAxeChoice(runInfoStatReader), dynamicTicks = TRUE) %>% style(hoverlabel = list(bgcolor = "white")) %>% plotlyConfig() #,tooltip = "text"
})

output$xAxeChoice <- renderUI({
	req(nrow(runInfoStatReader())>0)
	selectInput(
		"xaxe",
		"X axe",
		colnames(runInfoStatReader()),
		selected = "#READS"
	)
})

output$yAxeChoice <- renderUI({
	req(nrow(runInfoStatReader())>0)
	colToDrop = c("FLOWCELL","STARTTIME")
	colN = colnames(runInfoStatReader())
	colN = colN[! colN %in% colToDrop]

	selectInput(
		"yaxe",
		"Y axe",
		colN,
		selected = "QUALITY"
	)
})

output$groupByChoice <- renderUI({
	req(nrow(runInfoStatReader())>0,input$xaxe)

	if(input$xaxe == "FLOWCELL") {
		return()
	} else if(input$xaxe == "STARTTIME") {
		bins = c("Year","Month")
		return(selectInput(
			"groupBy",
			"",
			bins,
			selected="Month"
		))
	} else {
		slider.min=0
		slider.max = max(runInfoStatReader()[,get(input$xaxe)])
		lowestPowOf10 = 10**as.integer(log10(slider.max))
		slider.max = slider.max + lowestPowOf10
		slider.step = 0.01*lowestPowOf10

		return(sliderInput(
			"groupBy",
			"Bin size",
			min = slider.min,
			max = slider.max,
			step = slider.step,
			value = 0
		))
	}

	#bins = c(100000,1000000,10000000)
	# selectInput(
	# 	"groupBy",
	# 	"Bin size",
	# 	c("None",bins),
	# 	selected = "None"
	# )
})

output$ib_nbRunInProgress <- renderInfoBox({
	req(nrow(runInfoStatReader())>0)
	nb_runInProgress = length(runInfoStatReader()[ENDED=="NO",FLOWCELL])
	valueBox(
		nb_runInProgress,
		"Run in progress",
		icon = icon("cogs")
	)
})

output$ib_nbRuns <- renderInfoBox({
	req(nrow(runInfoStatReader())>0)
	nb_runs = nrow(runInfoStatReader())
	valueBox(
		nb_runs,
		"Runs sequenced",
		icon = icon("check-circle")
	)
})

output$ib_nbBases <- renderInfoBox({
	req(nrow(runInfoStatReader())>0)
	nb_bases = as.integer( sum(runInfoStatReader()[,get("YIELD(b)")]) / 1e+09 )
	valueBox(
		nb_bases,
		"GB sequenced",
		icon = icon("chart-line")
	)
})


# ______________________________________________________________________________________
# Click on a run of the graph to display the page of this run
#observeEvent(
#	event_data("plotly_click", source = "globalBar"),
#	{
#		d <- event_data("plotly_click", source = "globalBar")
#		updateSelectInput(
#			session,
#			"runList",
#			selected = d
#		)
#		updateTabItems(
#			session,
#			"menu",
#			selected = "run"
#		)
#	}
#)

