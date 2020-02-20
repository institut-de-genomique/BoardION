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
		column(width=2, uiOutput("tabComp_runs_xAxeChoice") ),
		column(width=2, uiOutput("tabComp_runs_yAxeChoice") ),
		column(width=2, uiOutput("tabComp_runs_groupByChoice"))
	),
	plotlyOutput("tabComp_runs_plot", height = "350px")
)

b_owr_time <- box(
	title = "Run comparison over time",
	collapsible = TRUE,
	width = 12,
	fluidRow( column(width=2, uiOutput("tabComp_cumul_yAxeChoice"))),
	h4("Cumulative"),
	plotlyOutput("tabComp_cumul_plot", height = "300px"),
	h4("Non cumulative"),
	plotlyOutput("tabComp_current_plot", height = "300px")
)

b_compPlotLength <- box(
	title = "Read length",
	collapsible = TRUE,
	width = 12,
	fluidRow(
		column(width=2, selectInput("tabComp_length_dropdown","y axe",c("Number of read","Number of base"))),
		column(width=2, checkboxInput( "tabComp_length_checkBox", "Percent", value=FALSE)),
	),
	plotlyOutput( "tabComp_length_plot", height="300px")
)

b_owr_comparison <- box(
	title = "Runs comparison",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width = 12,
	ms_comp,
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
