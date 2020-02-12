source('global.R')

ui <- dashboardPage(

  dashboardHeader(title = "Ukraine Iodine Survey"),

  dashboardSidebar(
    sidebarMenu(id="tabs",
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Cluster Data", tabName = "clusters", icon = icon("th")),
      menuItem("Building Data", tabName = "buildings", icon = icon("th")),
      menuItem("Dwelling Data", tabName = "dwellings", icon = icon("th")),
      menuItem("QR Test", tabName = "qrtest", icon = icon("th"))
    )
  ),


  dashboardBody(


    tabItems(

      # Dashboard Tab
      tabItem(tabName = "dashboard",
        fluidRow(
          column(
            width = 12,
            div(style="display: inline-block;vertical-align:top; width: 200px;",
            selectizeInput("region",
                           "Filter by Region",
                           regions_list,
                           options = list(
                                          placeholder = "Select a region",
                                          onInitialize = I('function() { this.setValue(""); }')
                            )
                       )
                 ),


            div(style="display: inline-block;vertical-align:top; width: 200px;",
                selectInput("cluster.id", label = "Select Cluster ID for Sampling", choices = clusters$id)
                ),

            div(style="display: inline-block; width: 200px;",
                br(),
                br(),

                downloadLink("downloadSample", "Download Sample of Dwellings")
                )
            
          ),
          column(
            width = 8,
            box(width = NULL, solidHeader = TRUE, height = "90vh", leafletOutput("mymap", height="85vh")
            )
          ),
          column(
            width = 4,
            h3("Region Kharkiv:"),
            h3("Cluster ID: 630431"),
            p("Selected cluster information will appear here."),
            br(),
            fluidRow(
              column(
                width = 3,
                h5("Cluster Status")    
              ),
              column(
                width = 6,
                h5(tags$strong("Building listing in progress"))
              )
            ),
            fluidRow(
              column(
                width = 3,
                h5("# of Buildings")    
              ),
              column(
                width = 6,
                h5(tags$strong("120"))
              )
            ),
            fluidRow(
              column(
                width = 3,
                h5("# Dwellings")    
              ),
              column(
                width = 6,
                h5(tags$strong("551"))
              )
            ),
          )
        )
      ),

      # Clusters Tab
      tabItem(tabName = "clusters",
              h2("Clusters Table"),
              fluidRow(column(width=12, DT::dataTableOutput('clusters')))
        ),

      # Building Tab
      tabItem(tabName = 'buildings',
              h2("Building Table"),
              fluidRow(column(12, DT::dataTableOutput('buildings')))
         ),

      # Dwellings Tab
      tabItem(tabName = 'dwellings',
              h2("Dwelling Table"),
              fluidRow(column(12, DT::dataTableOutput('dwellings')))
      ),

      tabItem(tabName = 'qrtest',
              h2("Some QR Code Tests"),
              plotOutput('qrtest')
      )
    )
  )
)