library(leaflet.extras)
library(dplyr)
source('./R/load_data.R')

regions_list <- setNames(regions$id,as.character(regions$name_en))

ui <- dashboardPage(
  dashboardHeader(title = "Ukraine Iodine Survey"),
  dashboardSidebar(
    sidebarMenu(id="tabs",
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Cluster Data", tabName = "clusters", icon = icon("th")),
      menuItem("Building Data", tabName = "buildings", icon = icon("th")),
      menuItem("Dwelling Data", tabName = "dwellings", icon = icon("th")),
      menuItem("Sampling", tabName = "sampling", icon = icon("th"))
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
               
          div(style="display: inline-block;float:right;padding:12px; font-size:100%",
              actionButton("create_sample", "Create Sample of Selected Cluster")),

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
       ),
    tabItem(tabName = 'dwellings',
            h2("Dwelling Table"),
            fluidRow(column(12, DT::dataTableOutput('dwellings')))
    ),
    tabItem(tabName = 'sampling',
            h2("Sampling Tool"),
            selectInput("cluster.id", label = "Select Cluster ID for Sampling", choices = clusters$id),
            downloadLink("downloadSample", "Download Sample of Dwellings")
    )

    )
  )
)


server <- function(input, output, session) {
  
  observeEvent(input$create_sample, {
    updateTabsetPanel(session, "tabs", selected = "sampling")})
  
  
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
  output$buildings<-DT::renderDataTable(DT::datatable(buildingsX,
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

  output$dwellings<-DT::renderDataTable(DT::datatable(dwellings,
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
  
  sampleDwellings<-reactive({
    sampleDwellings<-data.frame(Ukraine_sampling(dwellings, input$cluster.id))
  })
  
  
  output$downloadSample<- downloadHandler(
    
    filename = function() {
      paste(input$cluster.id,'-', Sys.Date(), '.csv', sep='')
    },
    
    
    content = function(con) {
      write.csv(sampleDwellings(), con,row.names=FALSE)
    }
  )
  
  
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
    leaflet() %>% addTiles() %>% addProviderTiles("Esri.WorldStreetMap") %>%
      addKML(country_shape, fillOpacity = 0) %>% 
      addMiniMap(
        tiles = providers$Esri.WorldStreetMap,
        toggleDisplay = TRUE
      )
    })

  ####################################
  # Dynamically Add cluster shapes and points based on chosen region
  ####################################
  observe({
  
    
    cluster_shapes <- filter_shapes()
    cluster_points <- filter_points()
    zoom_point <- zoom_to()
    
    leafletProxy("mymap") %>%
      clearShapes() %>%
      clearMarkers() %>%
      setView(lng = zoom_point$longitude, lat = zoom_point$latitude, zoom = zoom_point$zoom) %>%
      addPolygons(layerId = cluster_shapes$name, data = cluster_shapes , weight = 2, fillColor = "yellow", popup =paste("<h5><strong>",cluster_shapes$name,"</strong></h5>",
                                                                                       "<b>Id:</b>", cluster_shapes$id)) %>%
      addAwesomeMarkers(layerId = cluster_shapes$name, data = cluster_points, popup = paste("<h5>",cluster_points$name, "</h5>"))
  })
  
  ####################################
  # Dynamically add buildings based on chosen cluster
  ####################################
 zoom_to_cluster <- reactive({
    selected_cluster <- input$mymap_marker_click
    
    print(selected_cluster)
    return(selected_cluster)
  })
  
  selected_sample_cluster <- reactive({
    selected_sample_cluster <- input$mymap_marker_click
    
    print(selected_cluster$id)
  })
  
  values<-reactiveValues()
  values$id<-observe({selected_sample_cluster()})
  
  updateSelectInput(session, 
                    "cluster.id",
                    label = "Select Cluster ID for Sampling",
                    choices = clusters$id,
                    selected=values$id)
  
  zoom_to_cluster_by_shape <- reactive({
    selected_cluster <- input$mymap_shape_click
    
    print(selected_cluster)
    return(selected_cluster)
  })
  
  observe({
    selected_cluster <- zoom_to_cluster()
    if(!is.null(selected_cluster)) {
      filtered_buildings <- subset(buildings,cluster_id==selected_cluster['id'])

      if(nrow(filtered_buildings) > 0) {
          leafletProxy("mymap") %>%
            setView(lng = selected_cluster["lng"], lat = selected_cluster["lat"], zoom = 12) %>%
            clearMarkers() %>%
            addAwesomeMarkers(layerId = filtered_buildings$id, lng = filtered_buildings$longitude, lat = filtered_buildings$latitude, popup = paste("<h5>Structure No.: ", filtered_buildings$structure_number,"</h5><h5> # of Dwellings: ", filtered_buildings$num_dwellings), "</h5>")
      } else {
        leafletProxy("mymap") %>%
          setView(lng = selected_cluster["lng"], lat = selected_cluster["lat"], zoom = 12)
      }
    }
  })


  
  observe({
    selected_cluster <- zoom_to_cluster_by_shape()
    if(!is.null(selected_cluster)) {
      filtered_buildings <- subset(buildings,cluster_id==selected_cluster['id'])
      
      if(nrow(filtered_buildings) > 0) {
        leafletProxy("mymap") %>%
          setView(lng = selected_cluster["lng"], lat = selected_cluster["lat"], zoom = 12) %>%
          clearMarkers() %>%
          addAwesomeMarkers(layerId = filtered_buildings$id, lng = filtered_buildings$longitude, lat = filtered_buildings$latitude, popup = paste("<h5>Structure No.: ", filtered_buildings$structure_number,"</h5><h5> # of Dwellings: ", filtered_buildings$num_dwellings), "</h5>")  
      } else {
        leafletProxy("mymap") %>%
          setView(lng = selected_cluster["lng"], lat = selected_cluster["lat"], zoom = 12)
      }
      
    }
    
    })

  
}

shinyApp(ui = ui, server = server)
# adm@polygons[[1]]
