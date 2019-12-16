ms_comp<- selectizeInput(
	"compRunList",
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
		column(width=2, uiOutput("compGlobal_xAxeChoice") ),
		column(width=2, uiOutput("compGlobal_yAxeChoice") ),
		column(width=2, selectInput("compGlobal_typePlotChoice", "Plot type", c("scatter plot","bar plot","box plot","line plot")) ),
		column(width=2, uiOutput("compGlobal_groupByChoice"))
	),
	plotlyOutput("plot_axeChoice", height = "350px")
)

b_compPlotCumul <- box(

	title = "Cumulative",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width = 12,
	fluidRow( column(width=2, uiOutput("tabComp_yAxeChoice"))),
	plotlyOutput("plot_runCompTimeCumul", height = "300px")
)

b_compPlotCurrent <- box(

	title = "non-cumualtive",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width = 12,
#	fluidRow( column(width=2, uiOutput("tabComp_yAxeChoice"))),
	plotlyOutput("plot_runCompTimeCurrent", height = "300px")
)

tabComparison <- tabItem("comparison",
	fluidRow( ms_comp,
		  b_compPlotCumul,
		  b_compPlotCurrent
	)
)
