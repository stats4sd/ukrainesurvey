server <- function(input, output, session) {

  observeEvent(input$create_sample, {
    downloadLink("downloadSample", "Download Sample of Dwellings")
  })

  #####################################
  # Data table tabs
  #####################################
  output$clusters<-make_datatable(clusters)
  output$buildings<-make_datatable(buildings)
  output$dwellings<-make_datatable(dwellings)

  #####################################
  # Sample Dwellings within a cluster
  #####################################
  observe({
    selected_sample_cluster<- input$mymap_shape_click

    updateSelectInput(session,
                      "cluster.id",
                      label = "Select Cluster ID for Sampling",
                      choices = clusters$id,
                      selected=clusters$id[clusters$id==selected_sample_cluster['id']]
    )
  })
  
  ####################################
  # Initial Map Render
  ####################################
  output$mymap <- renderLeaflet({
    leaflet() %>% addTiles() %>% addProviderTiles("Esri.WorldStreetMap") %>%
      addKML(country_shape, fillOpacity = 0) %>%
      addMiniMap(
        tiles = providers$Esri.WorldStreetMap,
        toggleDisplay = TRUE
      )
    })

  ## zoom to region
  zoom_to <- reactive({
    if(input$region==""){
      return(data.frame(longitude = 31.165580, latitude = 48.379433, zoom = 6))
    }else{
      return(select(filter(regions, id == input$region), c(longitude,latitude,zoom)))
    }
  })

  ## filter cluster shapes
  filter_shapes <- reactive({
    if(input$region==""){

      return(shape_json)
    }else{
      filtered_clusters <- subset(clusters, region_id==input$region)
      return(subset(shape_json, name %in% filtered_clusters$id))
    }
  })


  ####################################
  # Dynamically Add cluster shapes and points based on chosen region
  ####################################
  observe({

    oblast_seleted <- subset(regions, id==input$region)
    cluster_shapes <- filter_shapes()
    zoom_point <- zoom_to()

    ## filter clusters completed and not completed
    clusters_process_not_completed<-subset(clusters, cluster_completed == FALSE | is.na(cluster_completed))
    clusters_process_completed<-subset(clusters, cluster_completed == TRUE)

    ## Clear map
    leafletProxy("mymap") %>%
      clearShapes() %>%
      clearMarkers() %>%
      setView(lng = zoom_point$longitude, lat = zoom_point$latitude, zoom = zoom_point$zoom)

    ## render completed clusters if they exist
    if(nrow(clusters_process_completed) > 0) {

      cluster_shapes_completed<-subset(cluster_shapes, name %in% clusters_process_completed$id)
      info_cluster_completed<-subset(clusters_process_completed, cluster_id==cluster_shapes_completed$name)

      leafletProxy("mymap") %>%
        addPolygons(layerId = cluster_shapes_completed$name,
                    data = cluster_shapes_completed ,
                    weight = 1,
                    fillColor = "green",
                    popup =paste("<h5><strong>Cluster",
                                 cluster_shapes_completed$name,
                                 " Completed</strong></h5>",
                                 "<b>Oblast:</b>", oblast_seleted$name_en,"</br>",
                                 "<b>Cluster Id:</b>", cluster_shapes_completed$name,"</br>",
                                 "<b>Dwellings Completed:</b>", info_cluster_completed$dwellings_completed,"</br>",
                                 "<b>Dwellings Not Completed:</b>",info_cluster_completed$dwellings_not_completed,"</br>",
                                 "<b>Dwellings Total:</b>",info_cluster_completed$tot_dwellings,"</br>"
                               )
                    )

    }

    ## render incomplete clusters if they exist
    if(nrow(clusters_process_not_completed) > 0) {

      cluster_shapes_not_completed <- subset(cluster_shapes, name %in% clusters_process_not_completed$id)
      info_cluster_not_completed<-subset(clusters_process_not_completed, cluster_id %in% cluster_shapes_not_completed$name)


      leafletProxy("mymap") %>%
        addPolygons(layerId = cluster_shapes_not_completed$name,
                    data = cluster_shapes_not_completed ,
                    weight = 1,
                    fillColor = "red",
                    popup =paste("<h5><strong>Cluster",
                                 cluster_shapes_not_completed$name," not Completed</strong></h5>",
                                 "<b>Oblast:</b>", oblast_seleted$name_en,"</br>",
                                 "<b>Cluster Id:</b>", cluster_shapes_not_completed$name,"</br>",
                                 "<b>Dwellings Completed:</b>", info_cluster_not_completed$dwellings_completed,"</br>",
                                 "<b>Dwellings Not Completed:</b>",info_cluster_not_completed$dwellings_not_completed,"</br>",
                                 "<b>Dwellings Total:</b>",info_cluster_not_completed$tot_dwellings,"</br>"
                                 )
                  )
    }

  })


  ####################################
  # Dynamically add buildings based on chosen cluster
  ####################################

  observe({
   selected_cluster <- input$mymap_shape_click

    if(!is.null(selected_cluster)) {

      building_file = paste0("Data/test/buildings_cluster", selected_cluster$id,".geojson")
      building_points = readOGR(building_file)
  
      # browser()
      
      leafletProxy("mymap") %>%
        setView(lng = selected_cluster["lng"], lat = selected_cluster["lat"], zoom = 13) %>%
        clearMarkers() %>%
        addCircleMarkers(data = building_points, 
                          radius = 5,
                          stroke = FALSE,
                          color = "blue",
                          popup = paste("<h5>Building number ", building_points$point
                                        )
                          )
        
        
      # 
      # # filtered_buildings <- subset(buildings,cluster_id==selected_cluster['id'])
      # # filtered_buildings_sample <- subset(buildings,cluster_id==selected_cluster['id'] & sum_sampled>0)
      # # filtered_buildings_not_sample <- subset(buildings,cluster_id==selected_cluster['id'] & (sum_sampled==0 | is.na(sum_sampled)))
      # 
      # if(nrow(filtered_buildings) > 0) {
      #   leafletProxy("mymap") %>%
      #     setView(lng = selected_cluster["lng"], lat = selected_cluster["lat"], zoom = 13) %>%
      #     clearMarkers() %>%
      #     addCircleMarkers(layerId = filtered_buildings_not_sample$id,
      #                      lng = filtered_buildings_not_sample$longitude,
      #                      lat = filtered_buildings_not_sample$latitude,
      #                      radius =5,
      #                      stroke=FALSE,
      #                      color = "grey",
      #                      fillOpacity = 0.4,
      #                      popup = paste("<h5>Structure No.: ",
      #                                    filtered_buildings_not_sample$structure_number,
      #                                    "</h5><h5> # of Dwellings: ",
      #                                    filtered_buildings_not_sample$num_dwellings,
      #                                    "</h5>"
      #                                    )
      #                      ) %>%
      #     addCircleMarkers(layerId = filtered_buildings_sample$id,
      #                      lng = filtered_buildings_sample$longitude,
      #                      lat = filtered_buildings_sample$latitude,
      #                      radius =5,
      #                      color = "blue",
      #                      stroke = FALSE,
      #                      fillOpacity = 0.6,
      #                      popup = paste("<h5>Structure No.: ",
      #                                    filtered_buildings_sample$structure_number,
      #                                    "</h5><h5> # of Dwellings: ",
      #                                    filtered_buildings_sample$num_dwellings,
      #                                    "</h5><h5>-----------", "<h5>", filtered_buildings_sample$text
      #                                    )
      #                      )
      # } else {
      #   leafletProxy("mymap") %>%
      #     setView(lng = selected_cluster["lng"], lat = selected_cluster["lat"], zoom = 12)
      # } #endif(buildings exist)
    } #endif(cluster is selected)

  }) #endobserve

}