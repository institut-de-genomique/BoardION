library(data.table)
library(ggplot2)
library(plotly)

# Unregular color gradient
myColorGrandient = c("#CC3D3D","#FFDD32","#B3D84B","#50B7C4")
myColorStep      = c(0,        0.3,      0.7,      1        )

# format big number
formatNumber <- function(x, d=2) {
	        return( format( x, nsmall = d, digits = d, scientific = FALSE, big.mark= ' ', drop0trailing = TRUE ))
}


# plot of the binned quality over time colored by another metric
# input: data.table (file quality_stat.txt), the name of the column used for coloring, a boolean to make the color log scale or not
# output: ggplot
plotQualityOverTime <- function(dt, colorColumn, doLogColor) {

	g <- ggplot( dt,
		aes(x=get("StepTime"),
		    y=get("Quality"),
		    fill=get(colorColumn),
		    text=paste('Duration (mn): ',formatNumber(StepTime),
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

# distribution of the read length (binned every 200 bases), the plot is initially zoomed on the n99 reads
# input: data.table (file readsLength.txt)
# output: plotly
plotReadLength <- function(dt) {

	# Get the N99 read length to limit the x axe on the plot
	dt[order(Length)] -> dt
	dt[,Cumulative:=cumsum(Count)]
	nbRead = dt$Cumulative[nrow(dt)]
	# get the Length column of the first row which have a Cumulative count over 99% of the number of read
	length99 = dt[Cumulative>(nbRead*.99)][1]$Length

	plot_ly(
		x=dt$Length,
		y=as.character(dt$Count),
		type = "histogram",
		histfunc = "sum",
		xbins = list(size=200)

	 ) %>% layout(
		yaxis=list(type='linear', ticks = "outside", showline = TRUE, title="Read count"),
		xaxis = list(range = c(0, length99), ticks = "outside", showgrid = TRUE, title="Read length (bases)")
	)
}

# plot of metric over time colored by another metric
# input: data.table (file globalstat.txt or currentstat.txt), the name of the column used on the y axis, the name of the column used for coloring
# output: ggplot
plotRunOverTime <- function(dt, y_col, color_col, color_limits=NULL) {

	g <- ggplot( dt,
		aes(x = get("Duration(mn)"),
		    y = get(y_col),
		    text = paste("Duration(mn): " ,get("Duration(mn)"),
				 "<br>",y_col,": ",formatNumber(get(y_col)),
				 "<br>",color_col,": ",formatNumber(get(color_col)),
				 sep=""
		   )
		)
	) +
	
	geom_col(aes(fill = get(color_col)), position="dodge", width = 10) +
	scale_fill_gradientn( colors=myColorGrandient, values=myColorStep, name=color_col, limits=color_limits) +

	theme_bw() +
	xlab("Duration(mn)") +
	ylab(y_col)
	
	return(g)
}

# Plot of multiple runs's metric over time
# input: data.table (concatenate files globalstat.txt or currentstat.txt), the name of the column used on the y axis
# output: ggplot
plotCompTime <- function(dt, y_axe) {

	ggplot( dt,
		aes(    x = get("Duration(mn)"),
			y = get(y_axe),
			col = RunID,
			group=1,
			text = paste( RunID,
				      '<br>Duration (mn): ',formatNumber(get("Duration(mn)")),
				      '<br>',y_axe,': ',formatNumber(get(y_axe)),
				      sep=""
			)
		)
	) +
	geom_line(size=0.5) +
	xlab("Duration (mn)") +
	ylab(y_axe) +
	theme_bw()
}

# Distribution of multiple runs read length
# input: data.table, mode="Number of base" or "Number of read", boolean distribution with log scale or not
# output: ggplot
plotCompReadLength <- function(x, mode, doPercent) {

	if(mode == "Number of base") {
		if(doPercent) {
			mapping = aes(x = Length, weight = PercentBase, col = RunID)
			y_name = "Percent of base number"
		} else {
			mapping = aes(x = Length, weight = NbBase, col = RunID)
			y_name = "Number of base"
		}
	} else {
		if(doPercent) {
			mapping = aes(x = Length, weight = PercentRead, col = RunID)
			y_name = "Percent of read number"
		} else {
			mapping = aes(x = Length, weight = Count, col = RunID)
			y_name = "Number of read"
		}
	}

	ggplot( x(),
		mapping
	) +
	ylab(y_name) +
	geom_freqpoly(size=0.5, binwidth=200) +
	xlab("Length") +
	theme_bw()
}

# plot main metrics of all runs 
# input: - data.table (file run_infostat.txt) 
#	- groupBy: value on which bin the x axis, it's "Month" or "Year" if the x axis is the date else it's a numeric value
#	- x axis column name
#	- y axis column name
# output: ggplot
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
	) + xlab(xAxe) + ylab(yAxe) + theme_bw()

	if(groupBy != 0 && groupBy != "None") {
		if(groupBy == "Month" || groupBy == "Year") {
			p <- p + geom_boxplot()
		} else {
			dt[,Group := as.factor(round(get(xAxe)/groupBy)*groupBy)] # compute bin for geom_boxplot
			p <- p + geom_boxplot(aes(x=Group,group=Group))
		}
	} else {

		if( xAxe == "RunID") {
			p <- p + geom_point(
				aes(
	  				text=paste(
						       xAxe,': ',get(xAxe),
						'<br>',yAxe,': ',get(yAxe),
						sep=''
					)
				)
			)
		} else {
			p <- p + geom_point(
				aes(
					text=paste(
						       xAxe,': ',get(xAxe),
						'<br>',yAxe,': ',get(yAxe),
						'<br>','RunID: ',RunID,
						sep=''
					)
				)
			)
		}
	}

	if( xAxe == "RunID" || xAxe == "Date" ) {
		p <- p + theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))
	}

	return(p)
}

# plot of the channel colored by a metric
# input: data.table (formatted file channel_stat.txt, see functions formatDataPromethion and formatDataGridion), the name of the column used for coloring
plotChannelStat <- function(dt, colVar) {
	ggplot(
		dt,
		aes(x=xcoord,
		    y=ycoord,
		    fill=get(colVar),
		    text=paste("Channel: ",formatNumber(Channel),
			       "<br>", colVar,": ",formatNumber(get(colVar)),
			       sep=""
			      )
		)
	) +
	geom_tile() +
	facet_grid(~n,scales="free_x") +

	scale_fill_gradientn(colors=myColorGrandient,values=myColorStep ,limits=c(0,NA), na.value="#E1E1E1") +
	scale_x_continuous(expand=c(0,0)) +
	scale_y_continuous(expand=c(0,0)) +

	theme_bw() +
	theme( # remove axis
		axis.line=element_blank(),
		axis.text=element_blank(),
		axis.title=element_blank(),
		axis.ticks=element_blank()
	) +

	labs(fill=colVar)
}

###
# Format channel dataset to plot a grid of channel

# create missing channels
# separate channels in 4 groups, like the interface on promethion
# transform the channel number into coordinate for the plot
formatDataPromethion <- function(x) {

	# create a new row in x for the missing channel with NA for all columns (except for channel)
	for (i in 1:3000) {
		if(nrow(x[Channel==i]) == 0) {
			x = rbindlist(list(x,list(Channel=i)), fill=T)
		}
	}

	x[is.na(x)] = -1

	# separate channel in 4 groups
	x$n = 1
	x[as.integer(as.character(Channel))<1501 & as.integer(as.character(Channel))>750,n:=2]
	x[as.integer(as.character(Channel))<2251 & as.integer(as.character(Channel))>1500,n:=3]
	x[as.integer(as.character(Channel))<3001 & as.integer(as.character(Channel))>2250,n:=4]

	# channel is a factor, convert it to integer to compute coordinate
	channel = as.integer(as.character(x$Channel))

	bigCol = as.integer( (channel-1) /250)
	val = (channel-1)%%250+1

	xcoord = (val-1)%%10+1
	ycoord = as.integer((val-1)/10)+1

	x$xcoord = xcoord + bigCol * 10
	x$ycoord = ycoord

	return(x)
}

# Also work for MinION
formatDataGridion <- function(x) {
	for (i in 1:512) {
		if(nrow(x[Channel==i]) == 0) {
			x = rbindlist(list(x,list(Channel=i)), fill=T)
		}
	}

	setkey( x, "Channel")

	x[is.na(x)] = -1

	x$n = rep( c(rep(1,32), rep(2,32)), 8 )

	channel = as.integer(as.character(x$Channel))

	x$ycoord = rep( rep(1:8,4),16)
	x$xcoord = c( rep( 1,8), rep( 2,8), rep( 3,8), rep( 4,8),
		      rep( 1,8), rep( 2,8), rep( 3,8), rep( 4,8),
		      rep(29,8), rep(30,8), rep(31,8), rep(32,8),
		      rep(29,8), rep(30,8), rep(31,8), rep(32,8),
		      rep(25,8), rep(26,8), rep(27,8), rep(28,8),
		      rep(25,8), rep(26,8), rep(27,8), rep(28,8),
		      rep(21,8), rep(22,8), rep(23,8), rep(24,8),
		      rep(21,8), rep(22,8), rep(23,8), rep(24,8),
		      rep(17,8), rep(18,8), rep(19,8), rep(20,8),
		      rep(17,8), rep(18,8), rep(19,8), rep(20,8),
		      rep(13,8), rep(14,8), rep(15,8), rep(16,8),
		      rep(13,8), rep(14,8), rep(15,8), rep(16,8),
		      rep( 9,8), rep(10,8), rep(11,8), rep(12,8),
		      rep( 9,8), rep(10,8), rep(11,8), rep(12,8),
		      rep( 5,8), rep( 6,8), rep( 7,8), rep( 8,8),
		      rep( 5,8), rep( 6,8), rep( 7,8), rep( 8,8)
		)

	return(x)
}
