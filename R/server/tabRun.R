# ______________________________________________________________________________________
# FILES READERS

globalStatReader <- reactive ({
	reactiveFileReader(
		intervalMillis = 60000,
		session	       = NULL,
		filePath       = paste(reportingFolder,"/",input$runList,"_globalstat.txt",sep=""),
		readFunc       = readCsvSpace
	)()
})

currentStatReader <- reactive ({
	reactiveFileReader(
		intervalMillis = 60000,
		session	       = NULL,
		filePath       = paste(reportingFolder,"/",input$runList,"_currentstat.txt",sep=""),
		readFunc       = readCsvSpace
	)()
})

qualityOverTimeReader <- reactive ({
	dt = reactiveFileReader(
		intervalMillis = 60000,
		session	       = NULL,
		filePath       = paste(reportingFolder,"/",input$runList,"_quality_stat.txt",sep=""),
		readFunc       = readCsvSpace
	)()

	dt[,LENGTHCUMUL:=LENGTH*`#READS`]
	return(dt)
})

readLengthReader <- reactive ({
	reactiveFileReader(
		intervalMillis = 60000,
		session	       = NULL,
		filePath       = paste(reportingFolder,"/",input$runList,"_readsLength.txt",sep=""),
		readFunc       = readCsvSpace
	)()
})

# ______________________________________________________________________________________
# PLOTS

plotRunNbBase <- function(x) {
	#plot_ly(x(), x = ~DURATION.mn., y = ~YIELD.b., type="bar") %>% plotlyConfig()
	#plot_ly(x, x = ~DURATION.mn., y = ~YIELD.b., type="scatter") %>% plotlyConfig()

	
	ggplot( x(),
		aes(x=get("DURATION(mn)"),
		    y=get("YIELD(b)"),
		    fill=QUALITY,
		    text=paste('DURATION (mn): ',get("DURATION(mn)"),
			       '<br>NB READS : ',format(get("YIELD(b)"), big.mark=' '),
			       '<br>QUALITY: ',QUALITY,
			       sep=""
			      )
		)
	) +
	
	geom_col(position="dodge", width = 10) +
	
	theme_bw() +
#	theme(text = element_text(size=20)) +
	scale_fill_gradientn(colors=myColorGrandient,values=myColorStep ,limits=c(0,15)) +
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
	scale_fill_gradientn(colors=myColorGrandient,values=myColorStep ,limits=c(0,15)) +
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
	scale_fill_gradientn(colors=myColorGrandient,values=myColorStep ,limits=c(0,15)) +
	xlab("Duration(mn)") +
	ylab("Speed (bases/min)") +
	labs(fill='Quality')
}


plotQualityOverTime <- function(x) {

	g <- ggplot( x(),
		aes(x=get("TEMPLATESTART"),
		    y=get("QUALITY"),
		    fill=get(input$qualityOverTime_col),
		    text=paste('Duration (mn): ',TEMPLATESTART,
			       '<br>Quality: ',QUALITY,
			       '<br>',input$qualityOverTime_col,': ',get(input$qualityOverTime_col),
			       sep=""
			      )
		)
	) +
	geom_tile(width=10,height=0.1) +

	theme_bw() +
	scale_x_continuous(expand=c(0,0)) +
	scale_y_continuous(expand=c(0,0)) +

	xlab("Duration(mn)") +
	ylab("Quality") +
	labs(fill=input$qualityOverTime_col)

	if(input$qualityOverTime_logCheckBox) {
		g <- g + scale_fill_gradientn(colors=myColorGrandient,values=myColorStep, na.value="#E1E1E1", trans="log10")
	} else {
		g <- g + scale_fill_gradientn(colors=myColorGrandient,values=myColorStep, na.value="#E1E1E1")
	}
	return(g)
}

plotReadLength <- function(x) {

	ggplot( x(),
		aes(x=LENGTH,
		    weight=COUNT
			text=paste('Length (b): ',LENGTH,
				   '<br>Count: ',COUNT,
				   sep=''
			)
		)
	) +
	geom_histogram(fill="#4f5dff",binwidth=1000) +

	theme_bw() +
	scale_x_continuous(expand=c(0,0)) +
	
	xlab("Length(b)") +
	ylab("Read count")
}

plotMulti <- function(x) {

	ggplot( x(),
		aes(x = get(input$trg_xc),
		    y = get(input$trg_yc),
		    fill = get(input$trg_cc)
		)
	) +
	geom_col(position="dodge", width = 10) +

	theme_bw() +
	scale_fill_gradientn(colors=myColorGrandient,values=myColorStep) +
	xlab(input$trg_xc) + 
	ylab(input$trg_yc)
}

# ______________________________________________________________________________________
# RENDER PLOT

output$plot_globalRunNbBase <- renderPlotly({
	req(nrow(globalStatReader())>0)
	ggplotly(plotRunNbBase(globalStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
})

output$plot_globalReadLength <- renderPlotly({
	req(nrow(readLengthReader())>0)
	ggplotly(plotReadLength(readLengthReader), tooltip = "text") %>% 
	layout(xaxis = list(range = c(-1000, 100000))) %>% # initial zoom
	plotlyConfig()
})

output$plot_currentRunNbBase <- renderPlotly({
	req(nrow(currentStatReader())>0)
	ggplotly(plotRunNbBase(currentStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
})

output$plot_currentRunNbRead <- renderPlotly({
	req(nrow(currentStatReader())>0)
	ggplotly(plotRunNbRead(currentStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
})

output$plot_currentRunSpeed <- renderPlotly({
	req(nrow(currentStatReader())>0)
	ggplotly(plotRunSpeed(currentStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
})

output$plot_qualityOverTime <- renderPlotly({
	req(input$qualityOverTime_col != "")
	req(nrow(qualityOverTimeReader())>0)
	ggplotly(plotQualityOverTime(qualityOverTimeReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
})

output$tabRunGlobal_plotAxeChoice <- renderPlotly({
	req(nrow(globalStatReader())>0)
	ggplotly(plotMulti(globalStatReader), dynamicTicks = TRUE)  %>% plotlyConfig()
})

# ______________________________________________________________________________________
# RENDER OTHER

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

output$runTable = DT::renderDataTable(
	runInfoStatReader()[FLOWCELL==input$runList],
	options = list(searching = FALSE, paging = FALSE)
)

output$qualityOverTime_colorMetricChoice <- renderUI({
        req(nrow(qualityOverTimeReader())>0)
	cn <- colnames(qualityOverTimeReader())
        cn = cn[ !cn %in% c("QUALITY","STARTTIME") ]
	selectInput(
		"qualityOverTime_col",
		"Select metric",
		cn,
		selected="#READS"
	)
})

output$tabRunGlobal_xAxeChoice <- renderUI({
	req(nrow(isolate(globalStatReader())) > 0)
	selectInput(
		"trg_xc",
		"X axe",
		colnames(isolate(globalStatReader())),
		selected="DURATION(mn)"
	)
})

output$tabRunGlobal_yAxeChoice <- renderUI({
	req(nrow(isolate(globalStatReader())) > 0)
	selectInput(
		"trg_yc",
		"Y axe",
		colnames(isolate(globalStatReader())),
		selected="SPEED(b/mn)"
	)
})

output$tabRunGlobal_colorChoice <- renderUI({
	req(nrow(isolate(globalStatReader())) > 0)
	selectInput(
		"trg_cc",
		"Color by",
		colnames(isolate(globalStatReader())),
		selected="QUALITY"
	)
})

# ______________________________________________________________________________________
# UPDATE

# update drop-down list of run
observe({

	runSelected = isolate(input$runList) # save the run selected before the update of the list
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
			runSelected = runInfoStatReader()[STARTTIME==max(na.omit(STARTTIME)),FLOWCELL] # if there isn't a run selected, take the most recent in the finished one (in progress run have NA in STARTTIME)
		}
	}
	
	updateSelectInput( 
		session,
		"runList",
		choice = listRun,
		selected = runSelected # use the selected run before the update, so that if runInfoStatReader() update the ui does not display the default run but the last one selected by the user
	)
})
