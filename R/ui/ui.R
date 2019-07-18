# ______________________________________________________________________________________
# FUNCTIONS

makeGraphBox <- function(name,id,width=6) {
	box(
		title = name,
		status = "primary",
		solidHeader = TRUE,
                collapsible = TRUE,
		width = width,
		plotlyOutput(paste("plot_",id,sep=""), height = "350px", inline=T)
	)
}


# ______________________________________________________________________________________
# HEADER

header <- dashboardHeader(title = "PromethIon dashboard")


# ______________________________________________________________________________________
# SIDEBAR

source("ui/sideBar.R")


# ______________________________________________________________________________________
# BODY    

source("ui/tabGlobal.R")
source("ui/tabRun.R")
source("ui/tabComparison.R")
#source("ui/tabTest2.R")

body <- dashboardBody (
	tabItems(
		tabGlobal,
		tabRun,
		tabComparison
	),
	tags$script(HTML("$('body').addClass('fixed');")) # Lock the header bar and the side bar
)


# ______________________________________________________________________________________
# MAIN UI

ui <- dashboardPage(title = 'PROM', header, sidebar, body, skin='blue')
