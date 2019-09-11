tabRunInProgress <- tabItem(
	"runInProgress",
	tags$script(
	'$(function(){
//		$("#coucou_maman2").on("DOMSubtreeModified", ".tab-content:first-of-type", function() {
//			$(this).css("height",$(".plot-container.plotly").outerHeight());
//		});

//		$(".tab-content").ready(function(){
//			$(this).css("height",$(".plot-container.plotly").outerHeight());
//		});
		

	});'
	),
	tags$div(id="coucou_maman2",
		fluidPage(
			DT::dataTableOutput("runIPTable"),
			tabBox(
				width=12,
				tabPanel(
					"Cumulative stat",
					column(width=6,solidHeader = FALSE,collapsible = FALSE,plotlyOutput("plot_globalRunIPYield",inline=TRUE) %>% withSpinner(type=6)),
					column(width=6,solidHeader = FALSE,collapsible = FALSE,plotlyOutput("plot_globalRunIPNbReads",inline=TRUE) %>% withSpinner(type=6))
					#makeGraphBox("Yield","globalRunIPYield",width=12,height="700px"),
				),
				tabPanel(
					"Last 10 minutes"
				)
			)
		)
	),
	width=12
)
