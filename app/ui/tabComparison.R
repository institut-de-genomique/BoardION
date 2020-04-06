ibo_ow_nbRunInProgress <- infoBoxOutput("ib_ow_nbRunInProgress",width=2)
ibo_ow_nbRuns <- infoBoxOutput("ib_ow_nbRuns",width=2)
ibo_ow_nbBases <- infoBoxOutput("ib_ow_nbBases",width=2)

ms_comp<- selectizeInput(
	"tabComp_runList",
	"Select runs",
	choices = c(),
	multiple = TRUE
)

b_compPlotGlobal <- box (
	title = "Runs overview",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width=12,
	fluidRow(
		column(width=3, uiOutput("tabComp_runs_xAxeChoice") ),
		column(width=3, uiOutput("tabComp_runs_yAxeChoice") ),
		column(width=3, uiOutput("tabComp_runs_groupByChoice")),
		column(width=2, makeRefreshButton("ab_owr_refreshRuns"))
	),
	plotlyOutput("tabComp_runs_plot", height = "350px") %>% withSpinner(type=6)
)

b_owr_time <- box(
	title = "Run comparison over time",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	collapsed = TRUE,
	width = 12,
	fluidRow( 
		column(width=3, uiOutput("tabComp_cumul_yAxeChoice")),
		makeRefreshButton("ab_owr_refreshCompTime")
	),
	h4("Since run start"),
	plotlyOutput("tabComp_cumul_plot", height = "300px") %>% withSpinner(type=6),
	h4("Every 10mn"),
	plotlyOutput("tabComp_current_plot", height = "300px") %>% withSpinner(type=6)
)

b_compPlotLength <- box(
	title = "Read length",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	collapsed = TRUE,
	width = 12,
	fluidRow(
		column(width=3, selectInput("tabComp_length_dropdown","Y axe",c("Number of read","Number of base"))),
		column(width=1, checkboxInput( "tabComp_length_checkBox", "Percent", value=FALSE), style="margin-top: 25px;"),
		makeRefreshButton("ab_owr_refreshCompLength")
	),
	plotlyOutput( "tabComp_length_plot", height="300px") %>% withSpinner(type=6)
)

b_owr_comparison <- box(
	title = "Runs comparison",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width = 12,
	fluidRow(
		column(width=11, ms_comp),
		makeRefreshButton("ab_owr_refreshComp") 
	),
	b_owr_time,
	b_compPlotLength
)

tabComparison <- tabItem(
  "comparison",
  fluidRow(
	   ibo_ow_nbRunInProgress,
	   ibo_ow_nbRuns,
	   ibo_ow_nbBases
  ),

  fluidRow(
    b_compPlotGlobal,
    b_owr_comparison
  )
)
