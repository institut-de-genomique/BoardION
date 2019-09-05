tabRunInProgress <- tabItem(
	"runInProgress",
#	tableOutput("runIPTable"),
	DT::dataTableOutput("runIPTable"),
	makeGraphBox("Yield","globalRunIPYield",width=12,height="700px"),
	width=12
)
