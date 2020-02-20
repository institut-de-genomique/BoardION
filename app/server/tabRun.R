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

	dt[,LengthCUMUL:=Length*`#Reads`]
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
	
	ggplot( x(),
		aes(x=get("Duration(mn)"),
		    y=get("Yield(b)"),
		    fill=Quality,
		    text=paste('Duration (mn): ',formatNumber(get("Duration(mn)")),
			       '<br>Yield(b) : ',formatNumber(get("Yield(b)")),
			       '<br>Quality: ',formatNumber(Quality),
			       sep=""
			      )
		)
	) +
	
	geom_col(position="dodge", width = 10) +
	
	theme_bw() +
	scale_fill_gradientn(colors=myColorGrandient,values=myColorStep ,limits=c(0,15)) +
	xlab("Duration(mn)") +
	ylab("Yield (bases)") +
	labs(fill='Quality')
}

plotRunNbRead <- function(x) {


	ggplot( x(),
		aes(x=get("Duration(mn)"),
		    y=get("#Reads"),
		    fill=Quality,
		    text=paste('Duration (mn): ',formatNumber(get("Duration(mn)")),
			       '<br>Nb Reads : ',formatNumber(get("#Reads")),
			       '<br>Quality: ',formatNumber(Quality),
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
		aes(x=get("Duration(mn)"),
		    y=get("Speed(b/mn)"),
		    fill=Quality,
		    text=paste('Duration (mn): ',formatNumber(get("Duration(mn)")),
			       '<br>Speed (b/mn): ',formatNumber(get("Speed(b/mn)")),
			       '<br>Quality: ',formatNumber(Quality),
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


plotQualityOverTime <- function(x, colorColumn, doLogColor) {

	g <- ggplot( x(),
		aes(x=get("TemplateStart"),
		    y=get("Quality"),
		    fill=get(colorColumn),
		    text=paste('Duration (mn): ',formatNumber(TemplateStart),
			       '<br>Quality: ',formatNumber(Quality),
			       '<br>',colorColumn,': ',formatNumber(get(colorColumn)),
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
	labs(fill=colorColumn)

	if(doLogColor) {
		g <- g + scale_fill_gradientn(colors=myColorGrandient,values=myColorStep, na.value="#E1E1E1", trans="log10")
	} else {
		g <- g + scale_fill_gradientn(colors=myColorGrandient,values=myColorStep, na.value="#E1E1E1")
	}
	return(g)
}

plotReadLength <- function(x) {

	ggplot( x(),
		aes(x=Length,
		    weight=Count
		)
	) +
	geom_histogram(fill="#4f5dff",binwidth=1000) +

	theme_bw() +
	scale_x_continuous(expand=c(0,0)) +
	
	xlab("Read length(b)") +
	ylab("Read count")
}

plotMulti <- function(data, x_col, y_col, color_col) {

	g <- ggplot( data(),
		aes(x = get(x_col),
		    y = get(y_col),
		    text = paste(x_col,": ",formatNumber(get(x_col)),
		                 "<br>",y_col,": ",formatNumber(get(y_col)),
		                 "<br>",color_col,": ",formatNumber(get(color_col)),
		                 sep=""
		   )
		)
	) 
	if(x_col == "Duration(mn)") { # if abcisse is duration -> barplot
		g <- g + geom_col(aes(fill = get(color_col)), position="dodge", width = 10) +
		scale_fill_gradientn( colors=myColorGrandient, values=myColorStep, name=color_col)
	} else {
		g <- g + geom_point(aes(col = get(color_col))) +
		scale_color_gradientn( colors=myColorGrandient, values=myColorStep, name=color_col)
	}

	g <- g + theme_bw() +
	xlab(x_col) + 
	ylab(y_col)
	return(g)
}

# ______________________________________________________________________________________
# RENDER PLOT

output$plot_globalRunNbBase <- renderPlotly({
	req(nrow(globalStatReader())>0)
	ggplotly(plotRunNbBase(globalStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
})

output$plot_globalReadLength <- renderPlotly({
	req(nrow(readLengthReader())>0)
	ggplotly(plotReadLength(readLengthReader), dynamicTicks = TRUE ) %>% #, tooltip = "text") %>% 
#	layout(xaxis = list(range = c(-1000, 105000))) %>% # initial zoom
	plotlyConfig()
})

output$tabRunGlobal_plotAxeChoice <- renderPlotly({
	req(nrow(globalStatReader())>0)
	req( !is.null(input$trg_xc))
	req( !is.null(input$trg_yc))
	req( !is.null(input$trg_cc))
	ggplotly(plotMulti(globalStatReader, input$trg_xc, input$trg_yc, input$trg_cc), dynamicTicks = TRUE, tooltip = "text")  %>% plotlyConfig()
})

output$plot_currentRunNbBase <- renderPlotly({
	req(nrow(currentStatReader())>0)
	ggplotly(plotRunNbBase(currentStatReader), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
})

output$tabRunCurrent_plotAxeChoice <- renderPlotly({
	req(nrow(currentStatReader())>0)
	req( !is.null(input$trc_xc))
	req( !is.null(input$trc_yc))
	req( !is.null(input$trc_cc))
	ggplotly(plotMulti(currentStatReader, input$trc_xc, input$trc_yc, input$trc_cc), dynamicTicks = TRUE, tooltip = "text")  %>% plotlyConfig()
})

output$qot_plot <- renderPlotly({
	req(nrow(qualityOverTimeReader())>0)
	req(input$qot_color)
	req(!is.null(input$qot_logCheckBox))
	ggplotly(plotQualityOverTime(qualityOverTimeReader, input$qot_color, input$qot_logCheckBox), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
})

# ______________________________________________________________________________________
# RENDER OTHER

output$runTitle <- renderText({
	req(input$runList != "")
	state = ""
	state = runInfoStatReader()[RunID==input$runList,Ended]
	
	if(state == "YES") {
		state = "COMPLETED"
	} else if(state == "NO") {
		state = "IN PROGRESS"
	}
	paste(input$runList," - ",state,sep="")
})

output$runTable = DT::renderDataTable(
	runInfoStatReader()[RunID==input$runList],
	options = list(searching = FALSE, paging = FALSE)
)

output$qot_colorMetricChoice <- renderUI({
        req(nrow(qualityOverTimeReader())>0)
	
	selectInput(
		"qot_color",
		"Select metric",
		vectRemove( colnames(qualityOverTimeReader()), c("Quality","StartTime","TemplateStart")),
		selected="#Reads"
	)
})

output$tabRunGlobal_xAxeChoice <- renderUI({
	req(nrow(isolate(globalStatReader())) > 0)

	selectInput(
		"trg_xc",
		"X axe",
		vectRemove( colnames(globalStatReader()), c("RunID")),
		selected="Duration(mn)"
	)
})

output$tabRunGlobal_yAxeChoice <- renderUI({
	req(nrow(isolate(globalStatReader())) > 0)
	selectInput(
		"trg_yc",
		"Y axe",
		vectRemove( colnames(globalStatReader()), c("RunID","Duration(mn)")),
		selected="Speed(b/mn)"
	)
})

output$tabRunGlobal_colorChoice <- renderUI({
	req(nrow(isolate(globalStatReader())) > 0)
	selectInput(
		"trg_cc",
		"Color by",
		vectRemove( colnames(globalStatReader()), c("RunID")),
		selected="Quality"
	)
})

output$tabRunCurrent_xAxeChoice <- renderUI({
	req(nrow(isolate(currentStatReader())) > 0)
	selectInput(
		"trc_xc",
		"X axe",
		vectRemove( colnames(currentStatReader()), c("RunID")),
		selected="Duration(mn)"
	)
})

output$tabRunCurrent_yAxeChoice <- renderUI({
	req(nrow(isolate(currentStatReader())) > 0)
	selectInput(
		"trc_yc",
		"Y axe",
		vectRemove( colnames(currentStatReader()), c("RunID","Duration(mn)")),
		selected="Speed(b/mn)"
	)
})

output$tabRunCurrent_colorChoice <- renderUI({
	req(nrow(isolate(currentStatReader())) > 0)
	selectInput(
		"trc_cc",
		"Color by",
		vectRemove( colnames(currentStatReader()), c("RunID")),
		selected="Quality"
	)
})


# ______________________________________________________________________________________
# UPDATE

# update drop-down list of run
observe({

	runSelected = isolate(input$runList) # save the run selected before the update of the list
	listRun = list()
	
	if(is.null(runInfoStatReader()) || nrow(runInfoStatReader())==0) {
		listRun <- character(0)
		runSelected = NULL
		
	} else {
		listRun = list(
			"In progress" = c("",ripList()), # add an empty slot, else the list doen not display correctly
			"Completed" = c(runList()[!runList() %in% ripList()])
		)

		if (runSelected == "" || is.null(runSelected)) {
			runSelected = runInfoStatReader()[StartTime==max(na.omit(StartTime)),RunID] # if there isn't a run selected, take the most recent one
		}
	}
	
	updateSelectInput( 
		session,
		"runList",
		choice = listRun,
		selected = runSelected # use the selected run before the update, so that if runInfoStatReader() update the ui does not display the default run but the last one selected by the user
	)
})
