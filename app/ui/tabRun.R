makeRunCustomablePlot <- function(name,w=12) {
	box(
		title = "Customable plot",
		status = "primary",
		solidHeader = TRUE,
		collapsible = TRUE,
		collapsed = TRUE,
		width=w,
		fluidRow(
			column(width=2, uiOutput(paste(name,"_xAxeChoice",sep="")) ),
			column(width=2, uiOutput(paste(name,"_yAxeChoice",sep="")) ),
			column(width=2, uiOutput(paste(name,"_colorChoice",sep=""))),
			column(width=2, makeRefreshButton(paste(name,"_refreshPlotChoice",sep="")))
		),
		plotlyOutput(paste(name,"_plotAxeChoice",sep=""), height = "350px") %>% withSpinner(type=6)
	)

}

makeRunChannelPlot <- function(name, w=12) {
	box(
		title = "Channels view",
		status = "primary",
		solidHeader = TRUE,
		collapsible = TRUE,
		collapsed = TRUE,
		width=w,
		fluidRow(
			column(width=2, uiOutput(paste(name,"_colorMetricChoice",sep=""))),
			column(width=2, makeRefreshButton(paste(name,"_refresh",sep="")))
		),
		plotlyOutput(paste(name,"_plot",sep=""), height = "350px") %>% withSpinner(type=6)
	)
}

makeRunQotPlot <- function(name, w=12) {
	box(
		title = "Quality over time",
		status = "primary",
		solidHeader = TRUE,
		collapsible = TRUE,
		collapsed = TRUE,
		width=w,
		fluidRow(
			column(width=2, uiOutput( paste(name, "_colorMetricChoice", sep="" ))),
			column(width=2, checkboxInput( paste( name, "_logCheckBox", sep=""), "Log10_color", value = FALSE )),
			column(width=2, makeRefreshButton(paste(name,"_refresh",sep="")))
		),
		plotlyOutput(paste(name,"_plot",sep=""), height = "500px") %>% withSpinner(type=6)
	)
}
tabRunGlobal <- tabPanel(

	"Cumlative stat",
	fluidRow(
		makeGraphBox("Yield","globalRunNbBase", width=6),
		makeGraphBox("Read length", "globalReadLength"),
		makeRunChannelPlot("channelCumul"),
		makeRunCustomablePlot("tabRunGlobal")
	)
)

tabRunCurrent <- tabPanel(
	"Real time stat",
	fluidRow(
		makeGraphBox("Yield","currentRunNbBase", width=12),
		makeRunQotPlot("qot"),
		makeRunCustomablePlot("tabRunCurrent")
	)
)

# liste deroulante avec la liste des run provenant du fichier run_infostat.txt
runListSelect <- selectInput(
	"runList",
	"Select a run",
	c()
)

runTitle <- textOutput("runTitle")

tabRun <- tabItem("run",
	fluidPage(
		column( width=12,
			h1(runTitle),
			fluidRow(
				column( width=2, runListSelect),
				makeRefreshButton("refreshTabRun")
			),
			DT::dataTableOutput("runTable"),
			tabBox( 
				width=12,
				tabRunGlobal,
				tabRunCurrent
			)
		)
	)
)
