# ______________________________________________________________________________________
# SIDEBAR

menu <- sidebarMenu(
	id = "menu",
	menuItem("Run in progress", tabName = "runInProgress"),
	menuItem("Run", tabName = "run"),	# stat sur un run
	menuItem("Comparison", tabName = "comparison")
)
	
sidebar <- dashboardSidebar(
	menu
)
