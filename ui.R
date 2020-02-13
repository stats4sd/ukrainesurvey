
library(shinyjs)
ui <- dashboardPage(

  dashboardHeader(title = "Ukraine Iodine Survey"),

  dashboardSidebar(
    sidebarMenu(id="tabs",
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("QR Test", tabName = "qrtest", icon = icon("th")),
      menuItem("Summary", tabName = "summary", icon = icon("file"))
    )
  ),


  dashboardBody(

    tabItems(

      # Dashboard Tab
      tabItem(tabName = "dashboard",
        fluidRow(
          column(
            width = 8,
            box(width = NULL, solidHeader = TRUE, height = "90vh", 
                leafletOutput("mymap", height="85vh"),
                
                    downloadButton('downloadPlot', 'Download Plot',class = "btn-primary", style="float: right;")
            ),
            
            column(width = 12,
        
                  DT::dataTableOutput("sampleTable"),
                  DT::dataTableOutput("checklistTable")
                  
            ),
          ),
          box(
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
          ),
          
          box(
            width = 4,
            div(style="display: inline-block;vertical-align:top; width: 200px;",
                selectizeInput("region",
                               "Filter by Region",
                               regions_list,
                               options = list(
                                 placeholder = "Select a region",
                                 onInitialize = I('function() { this.setValue(""); }')
                               )
                ),
                
            ),
            
            
            div(style="display: inline-block;vertical-align:top; width: 200px;",
                selectInput("cluster.id", label = "Select Cluster ID for Sampling", choices = clusters$id)
            ),
            
            div(style="display: inline-block; width: 200px;",
                br(),
                br(),
                
                #downloadLink("downloadSample", "Download Sample of Dwellings"),
                actionButton("generateSample", "Generate Sample", class = "btn-primary")
            ),
           
          )

        )
      ),

      tabItem(tabName = 'qrtest',
              h2("Some QR Code Tests"),
              plotOutput('qrtest')
      ),
      
      tabItem(tabName = 'summary',
              h2("Summary"),
              div(style="width: 200px;",
                  selectInput("cluster_summary", label = "Select Cluster ID for Sampling", choices = clusters$id)
              ),
              box(width=4,
                status="warning",
                h4('buildings listed'),
                p(clusters$tot_buildings)
              ),
              box(width=4,
                  status="warning",
                  h4('dwelligns listed'),
                  p(clusters$tot_dwellings)
              ),
              box(width=4,
                  status="warning",
                  h4('Total number of salt samples collected'),
                  p(3)
              ),
              box(width=4,
                  status="warning",
                  h4('Total number of 1st urine samples collected'),
                  p('33')
              ),
              box(width=4,
                  status="warning",
                  h4('Total number of 2nd urine samples collected'),
                  p('33')
              ),
              box(width=4,
                  status="warning",
                  h4('Number of completed and unsuccessful interviews '),
                  p('33')
              ),
              box(width=4,
                  status="warning",
                  h4('dwelligns visited uploaded to date'),
                  p('33'),
                  h5('Total number of interviews attempted'),
                  p('23'),
                  h5('Total number of interviews not completed'),
                  p('22'),
                  h5('Total number of completed (and successful) interviews'),
                  p('25'),
                  h5('Number of replacements'),
                  p('7'),
              ),
      )
    )
  )
)