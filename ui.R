jsfile <- "https://rawgit.com/rowanwins/leaflet-easyPrint/gh-pages/dist/bundle.js" 
ui <- dashboardPage(
  dashboardHeader(title = "Ukraine Iodine Survey"),

  dashboardSidebar(
    sidebarMenu(id="tabs",
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("QR Test", tabName = "qrtest", icon = icon("th")),
      menuItem("Replacement Sample", tabName = "replacement_sample", icon = icon("fas fa-exchange-alt")),
      menuItem("Cluster Summary", tabName = "cluster_summary", icon = icon("file")),
      menuItem("District Summary", tabName = "district_summary", icon = icon("file")),
      menuItem("Oblast Summary", tabName = "oblast_summary", icon = icon("file")),
      menuItem("National Summary", tabName = "national_summary", icon = icon("file"))
    )
  ),


  dashboardBody(
    useShinyjs(),

   
    tags$style("
                        .modal-lg {
                          width: 80vw; }
                         "),

    tags$head( tags$script(src = jsfile)
              ),
  
    


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
                  tags$li("Use the dropdown to select an oblast The map will zoom to show all clusters within that region."),
                  tags$li("Click on the cluster on the map, or use the dropdown box to select a cluster"),
                  tags$li("The map will load the listed buildings for the chosen cluster, along with any sample information present."),
                  tags$li("You can then perform key actions for the cluster")
                )
            )
          ),

          # map
          column(
            width = 8,

            box(width = NULL, solidHeader = TRUE, height = "90vh",

                leafletOutput("mymap", height="85vh")
                
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
                          label = "Select an Oblast",
                          choices = regions_list,
                          options = list(
                            placeholder = "Select an Oblast",
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
              )
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
                uiOutput("cluster_info"),
                hr(),

                div(
                  id = "sample_not_taken",
                  h5("If building listing is complete, click the button below to do the sampling."),
                  h5( class = "text-warning", "NOTE, Only proceed after you have confirmed this phase is complete. There is no going back once the sample has been taken!"),
                  actionButton("generate_sample_button", "Generate Sample", class = "btn-primary")
                ),

                div(
                  id = "sample_taken",
                  actionButton("download_sample", "Download Sample of dwellings sheet", class = "btn-primary")
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

      tabItem(tabName = 'replacement_sample',
              h2("Replacement Sample"),
              column(3,
                box(width = 12,
                    title = "Warning",
                    status = "warning",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    tags$ol(
                      tags$li("This is to generate replacement"),
                      tags$li("Only the supervisor are allowed to use this section")
                    ),
                ),
                box(width = 12,
                    title = "Show the replacements",
                    status = "info",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    selectizeInput("repl_region",
                                   label = "Select an Oblast",
                                   choices = regions_list,
                                   options = list(
                                     placeholder = "Select an Oblast",
                                     onInitialize = I('function() { this.setValue(""); }')
                                   )
                    ),
                    
                    selectizeInput("repl_cluster",
                                   label = "Select Cluster",
                                   choices = clusters$id,
                                   options = list(
                                     placeholder = "Select a cluster",
                                     onInitialize = I('function() { this.setValue(""); }')
                                   )
                    ),
                    div(id = "show_replacement",
                      tags$b(textOutput("replacement_number")),
                      br(),
                      br()
                    )
                ),
                div(id = "generate_replacement",
                  box(width = 12,
                      title = "Generate the replacements",
                      status = "info",
                      solidHeader = TRUE,
                      collapsible = TRUE,
                      p("if do you need more replacement select the number and click the button for generating new replacement"),
                      selectInput("repl_num", 
                                  label = "Select number of replacement", 
                                  choices = c(1,2,3,4,5,6,7,8)
                                  ),
                      
                      actionButton("generate_replacement", "Generate Replacement", class = "btn-primary", style="float:right")
                     
                      
                  )
                )
                   
              ),
              column(9,
              div( id = "replament_table",
                box(width = 12,
                    DT::dataTableOutput("replacementTable")
                    ),
              ),
              div(id = "error_message",
                box(width = 8,
                    title = "Error Message",
                    status = "danger",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    textOutput("message_error"),
                )
              ),
              )
      ),

      tabItem(tabName = 'cluster_summary',
              h2("Cluster Summary"),
              selectizeInput("filter_oblast_cs",
                             label = "Select an Oblast",
                             choices = regions_list,
                             options = list(
                               placeholder = "Select an Oblast",
                               onInitialize = I('function() { this.setValue(""); }')
                             )
              ),
              selectizeInput("filter_cluster_summary",
                             label = "Filter Cluster",
                             choices = clusters$id,
                             multiple = TRUE,
                             options = list(
                               placeholder = "Select a cluster",
                               onInitialize = I('function() { this.setValue(""); }')
                             )
              ),
              DT::dataTableOutput("clustersTable"),
              

      ),
      tabItem(tabName = 'district_summary',
              h2("Discrict Summary"),
              selectizeInput("filter_district_summary",
                             label = "Filter District",
                             choices = load_district_summary()$district_id,
                             multiple = TRUE,
                             options = list(
                               placeholder = "Select a district",
                               onInitialize = I('function() { this.setValue(""); }')
                             )
              ),
              DT::dataTableOutput("districtsTable"),
              
      ),
      tabItem(tabName = 'oblast_summary',
              h2("Oblast Summary"),
              selectizeInput("filter_oblast_summary",
                             label = "Select an Oblast",
                             choices = load_oblast_summary()$oblast_en,
                             multiple = TRUE,
                             options = list(
                               placeholder = "Select an Oblast",
                               onInitialize = I('function() { this.setValue(""); }')
                             )
              ),
              DT::dataTableOutput("oblastsTable"),
      ),

      tabItem(tabName = 'national_summary',
              h2("National Summary"),
              br(),

              box(width=3,
                  status="success",
                  h4('buildings listed'),
                   p(load_national_summary()$buildings_listed)
              ),
              box(width=3,
                  status="success",
                  h4('dwelligns listed'),
                  p(load_national_summary()$dwellings_listed)
              ),
              box(width=3,
                  status="success",
                  h4('Total number of salt samples collected'),
                  p(load_national_summary()$tot_salt_samples)
              ),
              box(width=3,
                  status="success",
                  h4('Total number of 1st urine samples collected'),
                  p(load_national_summary()$tot_1st_urine_samples_collected)
              ),
              box(width=3,
                  status="success",
                  h4('Total number of 2nd urine samples collected'),
                  p(load_national_summary()$tot_2st_urine_samples_collected)
              ),
              box(width=3,
                  status="success",
                  h4('Number of completed interviews'),
                  p(load_national_summary()$completed_interviews)
              ),
              box(width=3,
                  status="success",
                  h4('Number of unsuccessful interviews'),
                  p(load_national_summary()$unsuccessful_interviews)
              ),
              box(width=3,
                  status="success",
                  h4('dwelligns visited uploaded to date'),
                  p(load_national_summary()$dwellings_visited)
              ),
              box(width=3,
                  status="success",
                  h4('Total number of interviews attempted'),
                  p(load_national_summary()$interviews_attempted)
              ),
              box(width=3,
                  status="success",
                  h4('Total number of interviews not completed'),
                  p(load_national_summary()$interviews_not_completed)
              ),
              box(width=3,
                  status="success",
                  h4('Total number of completed (and successful) interviews'),
                  p(load_national_summary()$interviews_completed_successful)
              ),
              box(width=3,
                  status="success",
                  h4('Number of replacements'),
                  p(load_national_summary()$replacements_number)
              )
      )
    )
  )
)
