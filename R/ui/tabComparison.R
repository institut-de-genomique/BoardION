ms_comp<- selectizeInput(
	"tabComp_runList",
	"Choose runs",
	choices = c(),
	multiple = TRUE
)

b_compPlotGlobal <- box (
	title = "",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width=12,
	fluidRow(
		column(width=2, uiOutput("tabComp_runs_xAxeChoice") ),
		column(width=2, uiOutput("tabComp_runs_yAxeChoice") ),
		column(width=2, selectInput("tabComp_runs_typePlotChoice", "Plot type", c("scatter plot","bar plot","box plot","line plot")) ),
		column(width=2, uiOutput("tabComp_runs_groupByChoice"))
	),
	plotlyOutput("tabComp_runs_plot", height = "350px")
)

b_compPlotCumul <- box(
	title = "Cumulative",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width = 12,
	fluidRow( column(width=2, uiOutput("tabComp_cumul_yAxeChoice"))),
	plotlyOutput("tabComp_cumul_plot", height = "300px")
)

b_compPlotCurrent <- box(
  title = "non-cumulative",
  status = "primary",
  solidHeader = TRUE,
  collapsible = TRUE,
  width = 12,
  #	fluidRow( column(width=2, uiOutput("tabComp_current_yAxeChoice"))),
  plotlyOutput("tabComp_current_plot", height = "300px")
)

b_compPlotLength <- box(
	title = "Read length",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width = 12,
	plotlyOutput("tabComp_length_plot", height = "300px")
)

tabComparison <- tabItem(
  "comparison",
  fluidRow(
    b_compPlotGlobal,
    ms_comp,
    b_compPlotCumul,
    b_compPlotCurrent,
    b_compPlotLength
  )
)
