# ______________________________________________________________________________________
# FILENAMES

getGlobalStatFileName <- function() {
	return(getRunCumulativeFilePath(input$runList))
}

getCurrentStatFileName <- function() {
	return(getRunCurrentFilePath(input$runList))
}

getQotFileName <- function() {
	return(getRunQotFilePath(input$runList))
}

getLengthFileName <- function() {
	return(getRunLengthFilePath(input$runList))
}

# ______________________________________________________________________________________
# FILES READERS

globalStatReader      <- makeReactiveFileReader(getGlobalStatFileName)
currentStatReader     <- makeReactiveFileReader(getCurrentStatFileName)
qualityOverTimeReader <- makeReactiveFileReader(getQotFileName)        # dt[,LengthCUMUL:=Length*`#Reads`] # return(dt)
readLengthReader      <- makeReactiveFileReader(getLengthFileName)

# ______________________________________________________________________________________
# PLOTS

plotRunNbBase <- function(x) {
	
	ggplot( x,
		aes(x=get("Duration(mn)"),
		    y=get("Yield(b)"),
		    fill=Quality,
		    text=paste('Duration (mn): ',formatNumber(get("Duration(mn)")),
			       '<br>Yield (b) : ',formatNumber(get("Yield(b)")),
			       '<br>Quality: ',formatNumber(Quality),
			       sep=""
			      )
		)
	) +
	
	geom_col(position="dodge", width = 10) +
	
	theme_bw() +
	scale_fill_gradientn(colors=myColorGrandient,values=myColorStep ,limits=c(0,15)) +
	xlab("Duration (mn)") +
	ylab("Yield (bases)") +
	labs(fill='Quality')
}

plotRunNbRead <- function(x) {

	ggplot( x,
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
	xlab("Duration (mn)") +
	ylab("Number of reads") +
	labs(fill='Quality')
}

plotQualityOverTime <- function(x, colorColumn, doLogColor) {

	g <- ggplot( x,
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

	xlab("Duration (mn)") +
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

	plot_ly(
		x=x$Length,
		y=as.character(x$Count),
		type = "histogram",
		histfunc = "sum",
		xbins = list(size=200)
	
	 ) %>% layout(
		yaxis=list(type='linear'),
		xaxis = list(range = c(0, 5e+4))
	)
}


plotMulti <- function(data, x_col, y_col, color_col) {

	g <- ggplot( data,
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
	input$refreshTabRun
	isolate({
		req(nrow(globalStatReader())>0)
		ggplotly(plotRunNbBase(globalStatReader()), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
	})
})

output$plot_globalReadLength <- renderPlotly({
	input$refreshTabRun
	isolate({
		req(nrow(readLengthReader())>0)
		plotReadLength(readLengthReader()) %>% plotlyConfig()
	})
})

output$tabRunGlobal_plotAxeChoice <- renderPlotly({
	input$refreshTabRun
	input$tabRunGlobal_refreshPlotChoice
	isolate({
		req(nrow(globalStatReader())>0)
		if(input$refreshTabRun == 0 && input$tabRunGlobal_refreshPlotChoice == 0) {
			xAxe = "Duration(mn)"
			yAxe = "Speed(b/s)"
			colAxe = "Quality"
		} else {
			req( !is.null(input$trg_xc))
			req( !is.null(input$trg_yc))
			req( !is.null(input$trg_cc))
			xAxe = input$trg_xc
			yAxe = input$trg_yc
			colAxe = input$trg_cc
		}
		ggplotly(plotMulti(globalStatReader(), xAxe, yAxe, colAxe), dynamicTicks = TRUE, tooltip = "text")  %>% plotlyConfig()
	})
})

output$plot_currentRunNbBase <- renderPlotly({
	input$refreshTabRun
	isolate({
		req(nrow(currentStatReader())>0)
		ggplotly(plotRunNbBase(currentStatReader()), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
	})
})

output$tabRunCurrent_plotAxeChoice <- renderPlotly({
	input$refreshTabRun
	input$tabRunCurrent_refreshPlotChoice
	isolate({
		req(nrow(currentStatReader())>0)
		if(input$refreshTabRun == 0 && input$tabRunCurrent_refreshPlotChoice == 0) {
			xAxe = "Duration(mn)"
			yAxe = "Speed(b/s)"
			colAxe = "Quality"
		} else {
			req( !is.null(input$trc_xc))
			req( !is.null(input$trc_yc))
			req( !is.null(input$trc_cc))
			xAxe = input$trc_xc
			yAxe = input$trc_yc
			colAxe = input$trc_cc
		}
		ggplotly(plotMulti(currentStatReader(), xAxe, yAxe, colAxe), dynamicTicks = TRUE, tooltip = "text")  %>% plotlyConfig()
	})
})

output$qot_plot <- renderPlotly({
	input$refreshTabRun
	input$qot_refresh
	isolate({
		req(nrow(qualityOverTimeReader())>0)

		if(input$refreshTabRun == 0 && input$qot_refresh == 0 ){
			colAxe = "#Reads"
			doLog = 0
		} else {
			req(input$qot_color)
			req(!is.null(input$qot_logCheckBox))
			colAxe = input$qot_color
			doLog = input$qot_logCheckBox
		}
		ggplotly(plotQualityOverTime(qualityOverTimeReader(), colAxe, doLog), dynamicTicks = TRUE, tooltip = "text") %>% plotlyConfig()
	})
})

# ______________________________________________________________________________________
# RENDER OTHER

output$runTitle <- renderText({
	input$refreshTabRun
	isolate({
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
})

output$runTable = DT::renderDataTable(
	{
		input$refreshTabRun
		isolate({
			dt = runInfoStatReader()[RunID==input$runList]
			removeDTCol( dt, c("Date"))
			dt
		})
	},
	options = list(searching = FALSE, paging = FALSE)
)

output$qot_colorMetricChoice <- renderUI({
        req(nrow(qualityOverTimeReader())>0)

	isolate({
		selected = if(is.null(input$qot_color)) "#Reads" else input$qot_color
	})

	selectInput(
		"qot_color",
		"Select metric",
		vectRemove( colnames(qualityOverTimeReader()), c("Quality","StartTime","TemplateStart","TemplateDuration")),
		selected=selected
	)
})

output$tabRunGlobal_xAxeChoice <- renderUI({
	req(nrow(isolate(globalStatReader())) > 0)

	isolate({
		selected = if(is.null(input$trg_xc)) "Duration(mn)" else input$trg_xc
	})

	selectInput(
		"trg_xc",
		"X axe",
		vectRemove( colnames(globalStatReader()), c("RunID")),
		selected=selected
	)
})

output$tabRunGlobal_yAxeChoice <- renderUI({
	req(nrow(isolate(globalStatReader())) > 0)

	isolate({
		selected = if(is.null(input$trg_yc)) "Speed(b/s)" else input$trg_yc
	})

	selectInput(
		"trg_yc",
		"Y axe",
		vectRemove( colnames(globalStatReader()), c("RunID","Duration(mn)")),
		selected=selected
	)
})

output$tabRunGlobal_colorChoice <- renderUI({
	req(nrow(isolate(globalStatReader())) > 0)

	isolate({
		selected = if(is.null(input$trg_cc)) "Quality" else input$trg_cc
	})

	selectInput(
		"trg_cc",
		"Color by",
		vectRemove( colnames(globalStatReader()), c("RunID")),
		selected=selected
	)
})

output$tabRunCurrent_xAxeChoice <- renderUI({
	req(nrow(isolate(currentStatReader())) > 0)

	isolate({
		selected = if(is.null(input$trc_xc)) "Duration(mn)" else input$trc_xc
	})

	selectInput(
		"trc_xc",
		"X axe",
		vectRemove( colnames(currentStatReader()), c("RunID")),
		selected=selected
	)
})

output$tabRunCurrent_yAxeChoice <- renderUI({
	req(nrow(isolate(currentStatReader())) > 0)

	isolate({
		selected = if(is.null(input$trc_yc)) "Speed(b/s)" else input$trc_yc
	})

	selectInput(
		"trc_yc",
		"Y axe",
		vectRemove( colnames(currentStatReader()), c("RunID","Duration(mn)")),
		selected=selected
	)
})

output$tabRunCurrent_colorChoice <- renderUI({
	req(nrow(isolate(currentStatReader())) > 0)

	isolate({
		selected = if(is.null(input$trc_cc)) "Quality" else input$trc_cc
	})

	selectInput(
		"trc_cc",
		"Color by",
		vectRemove( colnames(currentStatReader()), c("RunID")),
		selected=selected
	)
})


# ______________________________________________________________________________________
# UPDATE

# update drop-down list of run
observe({

	runSelected = isolate(input$runList) # save the run selected before the update of the list
	listRun = list()
	
	runFinished = runList()[!runList() %in% ripList()]

	if(length(runFinished) == 0 && length(ripList()) == 0) {
		listRun <- character(0)
		runSelected = NULL

	} else {
		listRun = list(
			"In progress" = as.list(ripList()),
			"Completed" = as.list(runFinished)
		)
	}

	if (runSelected == "" || is.null(runSelected)) {
		runSelected = runInfoStatReader()[StartTime==max(na.omit(StartTime)),RunID] # if there isn't a run selected, take the most recent one
	}
	
	updateSelectInput( 
		session,
		"runList",
		choice = listRun,
		selected = runSelected # use the selected run before the update, so that if runInfoStatReader() update the ui does not display the default run but the last one selected by the user
	)
})
