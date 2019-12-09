ms_comp<- selectizeInput(
	"compRunList",
	"Choose runs",
	choices = c(),
	multiple = TRUE
)

b_compPlot <-box(

	title = "Cumulative",
	status = "primary",
	solidHeader = TRUE,
	collapsible = TRUE,
	width = 12,
	fluidRow( column(width=2, uiOutput("tabComp_yAxeChoice"))),
	plotlyOutput("plot_runCompTime", height = "300px")
)

tabComparison <- tabItem("comparison",
	fluidRow(ms_comp, b_compPlot)
)
