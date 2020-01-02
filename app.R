library(leaflet.extras)

source('./R/load_data.R')

regions_list <- setNames(regions$id,as.character(regions$name_en))

ui <- dashboardPage(
  dashboardHeader(title = "Ukraine Iodine Survey"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Cluster Data", tabName = "clusters", icon = icon("th")),
      menuItem("Building Data", tabName = "buildings", icon = icon("th"))
    )
  ),
  dashboardBody(
    #Boxes need to be put in a row (or column)
    tabItems(
    # First Tab content
    tabItem(tabName = "dashboard",
      fluidRow(
        column(width = 12,
               div(style="display: inline-block;vertical-align:top; width: 200px;",
                   selectInput("region", "Filter by Region",regions_list)
               ),
               div(style="display: inline-block;vertical-align:top; width: 300px;",
                   textOutput("region"))
                  ,

          box(width = NULL, solidHeader = TRUE, height = "90vh",

              leafletOutput("mymap", height="85vh")
          )
        )

      )
    ),
    # Cluster Table
    tabItem(tabName = "clusters",
            h2("Clusters Table"),
            fluidRow(column(width=12, DT::dataTableOutput('clusters')))
      ),
    # Building Table
    tabItem(tabName = 'buildings',
            h2("Building Table"),
            fluidRow(column(12, DT::dataTableOutput('buildings')))
       )

    )
  )
)


server <- function(input, output, session) {
  output$clusters<-DT::renderDataTable(DT::datatable(clusters,
                                                     extensions = 'Buttons',
                                                     filter = 'top',
                                                     options = list(
                                                       pageLength = 100,
                                                       dom = 'Blfrtip',
                                                       buttons = list(
                                                         list(
                                                           extend = "csv",
                                                           text = "Download as CSV file"
                                                           )
                                                         )
                                                      ),
                                                    class = "display"
                                                  ))
  
  #Building Table
  output$buildings<-DT::renderDataTable(DT::datatable(buildings,
                                                      extensions = 'Buttons',
                                                      filter = 'top',
                                                      options = list(
                                                        pageLength = 100,
                                                        dom = 'Blfrtip',
                                                        buttons = list(
                                                          list(
                                                            extend = "csv",
                                                            text = "Download as CSV file"
                                                          )
                                                        )
                                                      ),
                                                      class = "display"
  ))

  #Filter cluster by district

  # output$district_selected<-reactive({
  #   district_filter<-subset(district_table, district_table$description_district_boundaries ==input$district)
  #   clusters_table<-subset(clusters_table, clusters_table$district_id==district_filter$id)
  #   updateSelectInput(session, "cluster",
  #                   choices = c('all clusters',clusters_table$station_number))
  #  paste()
  # })
  #Filter shape from cluster selected
  filtered_shapes <- shape_json
  filtered_points <- point_json
  
  region <- reactive({
    if(input$region==""){
      filtered_shapes<-shape_json
    }else{
      filtered_clusters <- subset(clusters, region_id==input$region)
      filtered_shapes <- subset(shape_json, name %in% filtered_clusters$electoral_id)
      filtered_points <- subset(point_json, name %in% filtered_clusters$electoral_id)
    }
  })

  output$mymap <- renderLeaflet({
    
    leaflet() %>% addTiles() %>% addProviderTiles("Esri.WorldStreetMap") %>%
      setView(lng = 31.165580, lat = 48.379433, zoom = 6) %>%
      addPolygons(data = filtered_shapes , weight = 2, fillColor = "yellow", popup =paste("<h5><strong>",filtered_shapes$name,"</strong></h5>",
                                                                                  "<b>Id:</b>", filtered_shapes$id)) %>%
      addAwesomeMarkers(data = filtered_points, popup = paste("<h5>",filtered_points$name, "</h5>")) %>%
      addKML(country_shape, fillOpacity = 0)
    })

  output$region <- renderText({ paste("Selected Region: ", input$region) })

}

shinyApp(ui = ui, server = server)
# adm@polygons[[1]]
