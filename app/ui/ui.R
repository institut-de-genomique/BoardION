# ______________________________________________________________________________________
# FUNCTIONS

makeGraphBox <- function(name, id, width=6, height="350px", collapsed=FALSE) {
	box(
		title = name,
		status = "primary",
		solidHeader = TRUE,
                collapsible = TRUE,
		collapsed = collapsed,
		width = width,
#		background="navy",
		plotlyOutput(paste("plot_",id,sep=""), height = height, inline=T) %>% withSpinner(type=6)
	)
}

makeRefreshButton <- function(id) {
	actionButton(id, "", icon = icon("redo"), style="margin-top: 25px;" )
}

# ______________________________________________________________________________________
# HEADER

header <- dashboardHeader(title = "BoardION")


# ______________________________________________________________________________________
# SIDEBAR

source("ui/sideBar.R")


# ______________________________________________________________________________________
# BODY    

#source("ui/tabGlobal.R")
source("ui/tabRun.R")
source("ui/tabComparison.R")
source("ui/tabRunInProgress.R")

body <- dashboardBody (
	tabItems(
		#tabGlobal,
		tabRun,
		tabComparison,
		tabRunInProgress
	),

	# Lock the header bar and the side bar       
	tags$script(
		HTML("
			$(function(){
				$('body').addClass('fixed');
			});
		")
	),

	# style of the valueBox of run in progress	    
	tags$style(HTML("#rip_box .small-box {padding-top: 0px; padding-bottom: 0px; height: 60px; margin-bottom: 5px;} #rip_box .inner {padding-top: 0px; padding-bottom: 0px;} #rip_box h3 {margin-bottom: 0px; font-size: 33px;}"))
)


# ______________________________________________________________________________________
# MAIN UI

ui <- dashboardPage(title = 'BoardION', header, sidebar, body, skin='blue')
