library(leaflet.extras)

source('./R/load_data.R')

ui <- dashboardPage(
  dashboardHeader(title = "Ukraine"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
      # menuItem("Clusters", tabName = "clusters", icon = icon("th")),
      # menuItem("Building", tabName = "buildings", icon = icon("th"))
    )
  ),
  dashboardBody(
    #Boxes need to be put in a row (or column)
    tabItems(
    # First Tab content 
    tabItem(tabName = "dashboard",
      fluidRow(
        column(width = 12,
               # div(style="display: inline-block;vertical-align:top; width: 200px;",
               #     selectInput("district", "District",
               #                 c(unique(as.character(district_table$description_district_boundaries))),
               #                 verbatimTextOutput("selected_district")
               # 
               #     ),
               #     textOutput("district_selected")
               #     ),
               # div(style="display: inline-block;vertical-align:top; width: 200px;",
               #     selectInput("cluster", "Station Numbers",
               #                 choices = c('all clusters', unique(as.character(clusters_table$station_number))),
               #                 verbatimTextOutput("selected_cluster")
               #     ),
               #     textOutput("cluster_selected")
               #     ),
                   
              

          box(width = NULL, solidHeader = TRUE, height = "90vh",
              
              leafletOutput("mymap", height="80vh")
          )
        )
        
      )
    )
    # # Cluster Table
    # tabItem(tabName = "clusters",
    #         h2("Clusters Table"),
    #         fluidRow(column(12, dataTableOutput('cluster')))
    #   ),
    # # Building Table
    # tabItem(tabName = 'buildings',
    #         h2("Building Table"),
    #         fluidRow(column(12, dataTableOutput('buildings')))
    #    )
            
    )
  )
)


server <- function(input, output, session) {
  #Clusters Table
  # output$cluster<-DT::renderDataTable(DT::datatable(clusters_table, 
  #                                                extensions = 'Buttons',
  #                                                options = list(
  #                                                               dom = 'Blfrtip',
  #                                                               buttons = c('csv')
  #                                                               ),
  #                                                class = "display"
  #                                                  )
  #   )
  # #Building Table
  # output$buildings<-DT::renderDataTable(DT::datatable(buildings_table, 
  #                                                   extensions = 'Buttons',
  #                                                   options = list(
  #                                                     dom = 'Blfrtip',
  #                                                     buttons = c('csv')
  #                                                   ),
  #                                                   class = "display"
  #                                                   )
  #)
 
  #Filter cluster by district
 
  # output$district_selected<-reactive({
  #   district_filter<-subset(district_table, district_table$description_district_boundaries ==input$district)
  #   clusters_table<-subset(clusters_table, clusters_table$district_id==district_filter$id)
  #   updateSelectInput(session, "cluster",
  #                   choices = c('all clusters',clusters_table$station_number))
  #  paste()
  # })
  #Filter shape from cluster selected
  shapeFilter<-shape_json
  # cluster_selected <-reactive({
  # cluste_id<-input$cluster
  # if(cluste_id=="all clusters"){
  #   shapeFilter<-shape_json
  # }else{
  #   shapeFilter<-subset(shape_json, name==input$cluster)
  # }
  # })
  



  
  #Map
  
  icons <- awesomeIcons(
    icon = 'building',
    iconColor = 'black',
    markerColor = "blue",
    library = 'fa'
  )
  
  
  output$mymap <- renderLeaflet({
   
    leaflet() %>% addTiles() %>% addProviderTiles("Esri.WorldStreetMap") %>%
      setView(lng = 31.165580, lat = 48.379433, zoom = 7) %>% 
      # addAwesomeMarkers(data = shape_json, icon = icons, lng = 31.165580, lat = 48.379433) %>% 
      addPolygons(data = shape_json , weight = 2, fillColor = "yellow", popup =paste("<h5><strong>",shapeFilter$name,"</strong></h5>",
                                                                                  "<b>Id:</b>", shapeFilter$id)) %>% 
      addKML(country_shape, fillColor = "green", fillOpacity = 0)
    })
  
  ####
 
  
  ####
  
  
}

shinyApp(ui = ui, server = server)
# adm@polygons[[1]]
