# ______________________________________________________________________________________
# DATA STRUCTURES

# last position readed of a summary file to seek when reopened it
summaryStatLastFilePosition = 0

# sum of the data of the summary file per channel perl flowcell
reactive_val = reactiveValues(
				summaryStatSumDataCumul = data.table(),		# Cumul of statistiques per channel
				summaryStatSumDataCurrent = data.table()	# Cumul of statistiques per channel on the last update of the file summary_stat.txt
			)

# colnames of the summary file
summaryStatColNames = c()
			
# ______________________________________________________________________________________
# FILES READERS

readAndSavePos <- function(summaryStatfile) {

	# read file by chunk of 500 000 lines
	chunkSize = 5e+05
	summaryStat = data.table()
	
	# open file
	con = file(summaryStatfile,"r")
	
	# if a part of the file is already charged, read only from the last position else read all file
	if(summaryStatLastFilePosition > 0) {
		seek(con, where=summaryStatLastFilePosition)
		summaryStat = fread(text=readLines(con, n=chunkSize),col.names=summaryStatColNames)
		
	# else first line is the header	
	} else {
		summaryStat = fread(text=readLines(con, n=chunkSize))
		summaryStatColNames <<- colnames(summaryStat)[]
	}

	# save postion
	summaryStatLastFilePosition <<- seek(con)	
	close(con)

	return(summaryStat)
}

summaryStatReader <- reactive ({

	newdata = reactiveFileReader(
		intervalMillis = 60000,
		session	       = NULL,
		filePath       = "/env/cns/bigtmp2/abruno/promethion_app/test/test.tsv",
#		filePath       = "/env/cns/bigtmp2/abruno/promethion_app/test/summary_test.txt",
#		filePath       = paste(reportingFolder,"/",input$runList,"_globalstat.txt",sep=""),
		readFunc       = readAndSavePos
	)()

	print("HERE")
	print(dim(newdata))
	
	# reach end of file
	if(nrow(newdata) != 0) {
	
		# delete columns
		newdata[,c("filename_fastq","filename_fast5","read_id","run_id","mux","pore_type","experiment_id","passes_filtering"):=NULL]
		
		# set count of each observation to 1
		newdata[,count:=1]
		
		# rename column
		setnames(newdata,"sample_id","flowcell")
		
		# sum column of new data by flowcell and channel id
		reactive_val$summaryStatSumDataCurrent = newdata[, lapply(.SD, sum), by=.(flowcell,channel)]
		
		# add the new data to the cumulative data and sum column of new data by flowcell and channel id
		reactive_val$summaryStatSumDataCumul = rbindlist(list(isolate(reactive_val$summaryStatSumDataCumul),reactive_val$summaryStatSumDataCurrent))[, lapply(.SD, sum), by=.(flowcell,channel)]

		invalidateLater(100, session)
	}
})

# ______________________________________________________________________________________
# PLOTS

plotSummaryStat <- function(x) {
	
	ggplotly(
		
		ggplot(
			x, # take only data of the selected run !!!!!!!!!!!!!!!!!!!change condition value to input$runList!!!!!!!!!!!!!!!!!!!
			aes(	x=xcoord,
				y=ycoord,
				fill=mean,
				text=paste("CHANNEL: ",channel)
			)
		) +
		geom_raster() +
		theme_bw() +
		facet_grid(~n,scales="free_x") +
		

		theme_bw() +
		
		theme(	axis.line=element_blank(),
			axis.text=element_blank(),
			axis.title=element_blank(),
			axis.ticks=element_blank()
		) +
		
		scale_x_continuous(expand=c(0,0))  +
		scale_y_continuous(expand=c(0,0)) +
		
		scale_fill_gradientn(colors=rainbow(5),values=c(0,.5,.6,.7,1) ,limits=c(0,NA), na.value="#E1E1E1") 
		
		#labs(fill='Quality')
		
		#tooltip = "text"
	) %>% plotlyConfig()
}

# ______________________________________________________________________________________
# RENDERS
output$plot_channelStatCumul <- renderPlotly({
	summaryStatReader()
	if(!is.null(input$varChoice) & !is.null(reactive_val$summaryStatSumDataCumul)) {
		if(input$varChoice != "") {
			if(nrow(reactive_val$summaryStatSumDataCumul) > 0 ) {
				plotSummaryStat(formatData(reactive_val$summaryStatSumDataCumul,"PAD53745",input$varChoice)) # take only data of the selected run !!!!!!!!!!!!!!!!!!!change condition value to input$runList!!!!!!!!!!!!!!!!!!!
			}
		}
	}
})


output$channelStatCumul_colorMetricChoice <- renderUI({
	print(reactive_val$summaryStatSumDataCumul)
	colnames(reactive_val$summaryStatSumDataCumul) -> cn
	cn = cn[ !cn %in% c("flowcell","channel","count") ]
	
	selectInput(
		"varChoice",
		"Select metric",
		cn
	)
})

# ______________________________________________________________________________________
# FUNCTIONS

# subset data on the required flowcell
# create missing channel
# separate channel in 4 groups, like the interface on promethion
# compute the mean of the required column
# transform the channel number into coordinate for the plot
formatData <- function(x,flowcell,columnName) {

	# take only required flowcell
	x = x[flowcell==flowcell]

	# create a new row in x for the missing channel with NA for all columns (not for flowcell, channel and count)
	for (i in 1:3000) {
		if(length(x[channel==i,flowcell])) {
		} else {
			x = rbindlist(list(x,list(flowcell=flowcell,channel=i,count=1)), fill=T)
		}
	}
	
	x[is.na(x)] = -1
	
	# separate channel in 4 groups
	x$n = 1
	x[as.integer(as.character(channel))<2251 & as.integer(as.character(channel))>1500,n:=3]
	x[as.integer(as.character(channel))<3001 & as.integer(as.character(channel))>2250,n:=4]
	x[as.integer(as.character(channel))<1501 & as.integer(as.character(channel))>750,n:=2]
	
	# compute mean on required column
	x[,eval(parse(text=paste0("mean:=",columnName,"/count")))]
	
	# channel is a factor, convert it to integer to compute coordinate
	channel = as.integer(as.character(x$channel))

	bigCol = as.integer(  ( as.integer(channel) -1)  /250)
	val = (as.integer(channel)-1)%%250+1

	xcoord = (val-1)%%10+1
	ycoord = as.integer((val-1)/10)+1

	x$xcoord = xcoord + bigCol * 10
	x$ycoord = ycoord

	return(x)
}
