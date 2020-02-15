
library(shinyjs)
ui <- dashboardPage(
  

  dashboardHeader(title = "Ukraine Iodine Survey"),

  dashboardSidebar(
    sidebarMenu(id="tabs",
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("QR Test", tabName = "qrtest", icon = icon("th")),
      menuItem("Summary Cluster", tabName = "summary_cluster", icon = icon("file")),
      menuItem("Summary Region", tabName = "summary_region", icon = icon("file")),
      menuItem("Summary National", tabName = "summary_national", icon = icon("file"))
    )
  ),


  dashboardBody(
    tags$head(tags$script('
                        var dimension = [0, 0];
                        $(document).on("shiny:connected", function(e) {
                        dimension[0] = document.getElementById("mymap").clientWidth;
                        dimension[1] = document.getElementById("mymap").clientHeight;
                        Shiny.onInputChange("dimension", dimension);
                        });
                        $(window).resize(function(e) {
                        dimension[0] = document.getElementById("mymap").clientWidth;
                        dimension[1] = document.getElementById("mymap").clientHeight;
                        Shiny.onInputChange("dimension", dimension);
                        });
                        ')),
   

    tabItems(

      # Dashboard Tab
      tabItem(tabName = "dashboard",
        fluidRow(
          
          column(
            width = 12,
            box(width = 12,
                title = "Instructions", 
                status = "primary", 
                solidHeader = TRUE,
                collapsible = TRUE,
                tags$ol(
                  tags$li("Use the dropdown to select a region. The map will zoom to show all clusters within that region."),
                  tags$li("Click on the cluster on the map, or use the dropdown box to select a cluster"),
                  tags$li("The map will load the listed buildings for the chosen cluster, along with any sample information present."),
                  tags$li("You can then perform key actions for the cluster")
                )
          ),
          
          # map
          column(
            width = 8,
            box(width = NULL, solidHeader = TRUE, height = "90vh", 
                leafletOutput("mymap", height="85vh")
                # downloadButton("dl", "Download Map",class = "btn-primary", style="float: right;")
            )
          ),
          
          # filters
          column(
            width = 4,
            
            #filters
            box(
              width = 12,
              title = "Filters",
              solidHeader = TRUE,
              status = "primary",
              collapsible = TRUE,
              selectizeInput("region",
                          label = "Select a Region",
                          choices = regions_list,
                          options = list(
                            placeholder = "Select a region",
                            onInitialize = I('function() { this.setValue(""); }')
                          )
              ),
              
              selectizeInput("cluster", 
                             label = "Select Cluster", 
                             choices = clusters$id,
                             options = list(
                               placeholder = "Select a cluster",
                               onInitialize = I('function() { this.setValue(""); }')
                             )
              ),
              
              actionButton("generateSample", "Generate Sample", class = "btn-primary")

              
            ),
          
            # actions and summary column
            box(
              width = 12,
              title = "Cluster Information",
              solidHeader = TRUE,
              status = "primary",
              
              conditionalPanel(
                condition = "input.cluster == ''",
                h5("Select a cluster to show information here")
              ),
              
              conditionalPanel(
                condition = "input.cluster != ''",
              
                h3(textOutput("region_name")),
                h3(textOutput("cluster_name")),
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
                )
              )
            )
          ),
          
          column(width = 12,
                 
                 DT::dataTableOutput("sampleTable"),
                 DT::dataTableOutput("checklistTable")
                 
          )

        )
      ),

      tabItem(tabName = 'qrtest',
              h2("Some QR Code Tests"),
              plotOutput('qrtest')
      ),
      
      tabItem(tabName = 'summary_cluster',
              h2("Summary Cluster"),
              div(style="width: 200px;",
                  selectInput("summary_cluster", label = "Select Cluster ID for Sampling", choices = clusters$id)
              ),
              box(width=3,
                status="warning",
                h4('buildings listed')
                # p(sum_clusters$buildings_listed)
                
               
              ),
              box(width=3,
                  status="warning",
                  h4('dwelligns listed')
                  # p(sum_clusters$dwellings_listed)
              ),
              box(width=3,
                  status="warning",
                  h4('Total number of salt samples collected'),
                  p(3)
              ),
              box(width=3,
                  status="warning",
                  h4('Total number of 1st urine samples collected'),
                  p('33')
              ),
              box(width=3,
                  status="warning",
                  h4('Total number of 2nd urine samples collected'),
                  p('33')
              ),
              box(width=3,
                  status="warning",
                  h4('Number of completed interviews')
                  # p(load_summary_clusters(clusters$id[1])$interviews_completed)
              ),
              box(width=3,
                  status="warning",
                  h4('Number of unsuccessful interviews')
                  # p(load_summary_clusters(clusters$id[1])$interviews_incompleted)
              ),
              box(width=3,
                  status="warning",
                  h4('dwelligns visited uploaded to date'),
                  p('33')
              ),
              box(width=3,
                  status="warning",
                  h4('Total number of interviews attempted'),
                  p('23')
              ),
              box(width=3,
                  status="warning",
                  h4('Total number of interviews not completed'),
                  p('22')
              ),
              box(width=3,
                  status="warning",
                  h4('Total number of completed (and successful) interviews'),
                  p('25')
              ),
              box(width=3,
                  status="warning",
                  h4('Number of replacements'),
                  p('7')
              )
       
      ),
      tabItem(tabName = 'summary_region',
              h2("Summary Region"),
              div(style="width: 200px;",
                  selectizeInput("summary_region",
                                 "Filter by Region",
                                 regions_list,
                                 options = list(
                                   placeholder = "Select a region",
                                   onInitialize = I('function() { this.setValue(""); }')
                                 )
                  )
                  
              ),
              
              box(width=3,
                  status="info",
                  h4('buildings listed')
                  # p(load_summary_clusters(clusters$id[1])$buildings_listed)
              ),
              box(width=3,
                  status="info",
                  h4('dwelligns listed')
                  # p(load_summary_clusters(clusters$id[1])$dwellings_listed)
              ),
              box(width=3,
                  status="info",
                  h4('Total number of salt samples collected'),
                  p(3)
              ),
              box(width=3,
                  status="info",
                  h4('Total number of 1st urine samples collected'),
                  p('33')
              ),
              box(width=3,
                  status="info",
                  h4('Total number of 2nd urine samples collected'),
                  p('33')
              ),
              box(width=3,
                  status="info",
                  h4('Number of completed interviews')
                  # p(load_summary_clusters(clusters$id[1])$interviews_completed)
              ),
              box(width=3,
                  status="info",
                  h4('Number of unsuccessful interviews')
                  # p(load_summary_clusters(clusters$id[1])$interviews_incompleted)
              ),
              box(width=3,
                  status="info",
                  h4('dwelligns visited uploaded to date'),
                  p('33')
              ),
              box(width=3,
                  status="info",
                  h4('Total number of interviews attempted'),
                  p('23')
              ),
              box(width=3,
                  status="info",
                  h4('Total number of interviews not completed'),
                  p('22')
              ),
              box(width=3,
                  status="info",
                  h4('Total number of completed (and successful) interviews'),
                  p('25')
              ),
              box(width=3,
                  status="info",
                  h4('Number of replacements'),
                  p('7')
              )
             
              
      ),
      
      tabItem(tabName = 'summary_national',
              h2("Summary National"),
              br(),
              
              box(width=3,
                  status="success",
                  h4('buildings listed'),
                  p(load_summary_clusters(clusters$id[1])$buildings_listed)
              ),
              box(width=3,
                  status="success",
                  h4('dwelligns listed'),
                  p(load_summary_clusters(clusters$id[1])$dwellings_listed)
              ),
              box(width=3,
                  status="success",
                  h4('Total number of salt samples collected'),
                  p(3)
              ),
              box(width=3,
                  status="success",
                  h4('Total number of 1st urine samples collected'),
                  p('33')
              ),
              box(width=3,
                  status="success",
                  h4('Total number of 2nd urine samples collected'),
                  p('33')
              ),
              box(width=3,
                  status="success",
                  h4('Number of completed interviews'),
                  p(load_summary_clusters(clusters$id[1])$interviews_completed)
              ),
              box(width=3,
                  status="success",
                  h4('Number of unsuccessful interviews'),
                  p(load_summary_clusters(clusters$id[1])$interviews_incompleted)
              ),
              box(width=3,
                  status="success",
                  h4('dwelligns visited uploaded to date'),
                  p('33')
              ),
              box(width=3,
                  status="success",
                  h4('Total number of interviews attempted'),
                  p('23')
              ),
              box(width=3,
                  status="success",
                  h4('Total number of interviews not completed'),
                  p('22')
              ),
              box(width=3,
                  status="success",
                  h4('Total number of completed (and successful) interviews'),
                  p('25')
              ),
              box(width=3,
                  status="success",
                  h4('Number of replacements'),
                  p('7')
              )
              
      )
      )
    )
  )
)