library(leaflet.extras)
library(dplyr)
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
                   selectizeInput(
                     "region", 
                     "Filter by Region",
                     regions_list, 
                     options = list(
                       placeholder = "Select a region", 
                       onInitialize = I('function() { this.setValue(""); }')
                       )
                     )
               ),

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

  #Filter shape from cluster selected
  filtered_shapes <- shape_json
  filtered_points <- point_json
  
  zoom_to <- reactive({
    if(input$region==""){
      return(data.frame(longitude = 31.165580, latitude = 48.379433, zoom = 6))
    }else{
      return(select(filter(regions, id == input$region), c(longitude,latitude,zoom)))
    }
  })

  filter_shapes <- reactive({
    if(input$region==""){
      return(shape_json)
    }else{
      filtered_clusters <- subset(clusters, region_id==input$region)
      return(subset(shape_json, name %in% filtered_clusters$id))
    }
  })

  filter_points <- reactive({
    if(input$region==""){
        return(point_json)
    }else{
        filtered_clusters <- subset(clusters, region_id==input$region)
        return(subset(point_json, name %in% filtered_clusters$id))
    }
    })

  output$mymap <- renderLeaflet({
    cluster_shapes <- filter_shapes()
    cluster_points <- filter_points()
    zoom_point <- zoom_to()
    print(zoom_point)
    leaflet() %>% addTiles() %>% addProviderTiles("Esri.WorldStreetMap") %>%
      setView(lng = zoom_point$longitude, lat = zoom_point$latitude, zoom = zoom_point$zoom) %>%
      addPolygons(data = cluster_shapes , weight = 2, fillColor = "yellow", popup =paste("<h5><strong>",cluster_shapes$name,"</strong></h5>",
                                                                                  "<b>Id:</b>", cluster_shapes$id)) %>%
      addAwesomeMarkers(data = cluster_points, popup = paste("<h5>",cluster_points$name, "</h5>")) %>%
      addKML(country_shape, fillOpacity = 0) %>% 
      addMiniMap(
        tiles = providers$Esri.WorldStreetMap,
        toggleDisplay = TRUE
      )
    })
  

  
}

shinyApp(ui = ui, server = server)
# adm@polygons[[1]]
