# ______________________________________________________________________________________
# FILES READERS

coerceToFunc <- function(x) {
  force(x);
  if (is.function(x))
    return(x)
  else
    return(function() x)
}

reactiveMultiFileReader <- function(intervalMillis, session, filesPath, readFunc, ...) {
	filesPath <- coerceToFunc(filesPath)
	extraArgs <- list(...)

	reactivePoll(
		intervalMillis, session,
		function() {
			value = ""
			for(path in filesPath()) {
				info <- file.info(path)
				paste(value,path, info$mtime, info$size)
			}
			return(value)
		},
		function() {
			dt = data.table()
			for(path in filesPath()) {
				dt <- rbind(dt,do.call(readFunc, c(path, extraArgs)))
			}
			return(dt)
		}
	)
}

runIPGlobalStatReader <- reactive ({

	runsIP = runInfoStatReader()[ENDED=="NO",FLOWCELL]

		reactiveMultiFileReader(
		intervalMillis  = 60000,
		session	        = NULL,
		filesPath       = paste(reportingFolder,"/",runsIP,"_globalstat.txt",sep=""),
		readFunc        = readCsvSpace
	)()

})

# ______________________________________________________________________________________
# PLOT

plotRunIPYield <- function(x) {
	ggplot( x(),
		aes(x=get("DURATION(mn)"),
		    y=get("YIELD(b)"),
		    fill=QUALITY,
		    text=paste('DURATION (mn): ',get("DURATION(mn)"),
			       '<br>NB READS : ',format(get("YIELD(b)"), big.mark=' '),
			       '<br>QUALITY: ',QUALITY,
			       '<br>',FLOWCELL,
			       sep=""
			      )
		)
	) +
	geom_col( position="dodge", width = 10) +

	theme_bw() +
	scale_fill_gradientn(colors=myColorGrandient,values=myColorStep ,limits=c(0,15)) +
	xlab("Duration(mn)") +
	ylab("Yield (bases)") +
	labs(fill='Quality')
}


# ______________________________________________________________________________________
# RENDER

output$runIPTable = DT::renderDataTable(
	runInfoStatReader()[ENDED=="NO"]
)

rip_filesReaders <- reactiveValues() # Contain the reactiveFileReader
rip_runDisplayed = reactiveValues() # trace for which run an ui output exist

observeEvent( input$rip_cumulative_toggle, {

	if(input$rip_cumulative_toggle) {
		for(flowcell in names(rip_runDisplayed)) {
			rip_filesReaders[[ paste("rip_yield_", flowcell, sep="") ]] <- reactiveFileReader(intervalMillis = 60000, session = NULL, filePath = paste( reportingFolder, "/", flowcell, "_globalstat.txt", sep=""), readFunc = readCsvSpace)
		}
	} else {
		for(flowcell in names(rip_runDisplayed)) {
			rip_filesReaders[[ paste("rip_yield_", flowcell, sep="") ]] <- reactiveFileReader(intervalMillis = 60000, session = NULL, filePath = paste( reportingFolder, "/", flowcell, "_currentstat.txt", sep=""), readFunc = readCsvSpace)
		}
	}
})

observeEvent( rip(), {

	for(flowcell in rip()) {

		if( !flowcell %in% names(rip_runDisplayed) ) { # if the run insn't displayed yet
		
			local({
				fc <- flowcell

				rip_runDisplayed[[flowcell]] = TRUE
	
				# id of the ui element
				plotYieldID  <- paste("rip_yield_", fc, sep="")
				plotLengthID <- paste("rip_length_", fc, sep="")
				valBox30ID   <- paste("rip_length_sup30_",fc,sep="")
				valBox50ID   <- paste("rip_length_sup50_",fc,sep="")
				valBox100ID  <- paste("rip_length_sup100_",fc,sep="")
				containerID  <- paste("rip_container_",fc,sep="")

				# create dynamic reader and save it in reactiveValues

				if(input$rip_cumulative_toggle) {
					rip_filesReaders[[plotYieldID]]  <- reactiveFileReader(intervalMillis = 60000, session = NULL, filePath = paste( reportingFolder, "/", fc, "_globalstat.txt", sep=""), readFunc = readCsvSpace)
				} else {
					rip_filesReaders[[plotYieldID]]  <- reactiveFileReader(intervalMillis = 60000, session = NULL, filePath = paste( reportingFolder, "/", fc, "_currentstat.txt", sep=""), readFunc = readCsvSpace)
				}

				rip_filesReaders[[plotLengthID]] <- reactiveFileReader(intervalMillis = 60000, session = NULL, filePath = paste( reportingFolder, "/", fc, "_readsLength.txt", sep=""), readFunc = readCsvSpace)

				insertUI( # create a box per run with plotoutput
					selector = '#placeholder',
					where = "afterEnd",
					ui = tags$div( id = containerID,
						box( title = fc, width = NULL, status = "primary", solidHeader = TRUE, collapsible = TRUE, collapsed = TRUE,
							fluidRow(
								column(5, plotlyOutput(plotYieldID, height = 300) %>% withSpinner(type=6) ),
								column(5, plotlyOutput(plotLengthID, height = 300) %>% withSpinner(type=6) ),
								column(2, valueBoxOutput(valBox30ID, width=NULL), valueBoxOutput(valBox50ID, width=NULL), valueBoxOutput(valBox100ID, width=NULL))
							)
						)
					)
				)

				output[[plotYieldID]] <- renderPlotly({
					p <- ggplotly( plotRunIPYield(rip_filesReaders[[plotYieldID]]), dynamicTicks = TRUE, tooltip = "text")
					p %>% style(marker.colorbar.len = 1, traces = length(p$x$data))  %>% # make the height colorbar (legend on the side of the plot) equal to the height of the plot
					plotlyConfig()
				})

				output[[plotLengthID]] <- renderPlotly({
					rip_filesReaders[[plotLengthID]] %>%
					plotReadLength() %>%
					ggplotly(dynamicTicks = FALSE) %>% # can't use dynamicTicks and make an initial zoom with layout
					layout(xaxis = list(range = c(-1000, 105000))) %>%
					plotlyConfig()
				})

				output[[valBox30ID]] <- renderValueBox({
					valueBox( sum(rip_filesReaders[[plotLengthID]]()[LENGTH>=30000, COUNT]), "reads > 30kb")
				})

				output[[valBox50ID]] <- renderValueBox({
					valueBox( sum(rip_filesReaders[[plotLengthID]]()[LENGTH>=50000, COUNT]), "reads > 50kb")
				})

				output[[valBox100ID]] <- renderValueBox({
					valueBox( sum(rip_filesReaders[[plotLengthID]]()[LENGTH>=100000, COUNT]), "reads > 100kb")
				})
			})
					
		}

	}

	for(flowcell in names(rip_runDisplayed)) {

		if(!flowcell %in% rip()) { # id a displayed run insn't a run in progress anymore (it's ended) remove it
			containerID <- paste("rip_container_",flowcell,sep="")
			rip_runDisplayed$flowcell <- NULL
			selector = paste0("#", containerID)
			removeUI(selector)
		}
	}
})
