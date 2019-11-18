ibo_nbRunInProgress <- infoBoxOutput("ib_nbRunInProgress",width=2)
ibo_nbRuns <- infoBoxOutput("ib_nbRuns",width=2)
ibo_nbBases <- infoBoxOutput("ib_nbBases",width=2)

b_axeChoice <-box(
	title = "",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width=12,
	fluidRow(
		column(width=2, uiOutput("xAxeChoice") ),
		column(width=2, uiOutput("yAxeChoice") ),
		column(width=2, selectInput("typePlotChoice", "Plot type", c("scatter plot","bar plot","box plot","line plot")) ),
		column(width=2, uiOutput("groupByChoice"))
	),
	plotlyOutput("axeChoice", height = "350px")
)

b_nbReadRun <- box(
	title = "Yield per run",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width=12,
	plotlyOutput("nbReadRun", height = "300px")
)

tabGlobal <- tabItem("global",
	fluidRow(ibo_nbRunInProgress,ibo_nbRuns,ibo_nbBases),
	fluidRow( 
		column( 
			width=12,
			b_nbReadRun,
			b_axeChoice
		)
	)
)
