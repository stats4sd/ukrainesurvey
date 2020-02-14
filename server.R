library (plyr)

server <- function(input, output, session) {
value= FALSE
  observeEvent(input$create_sample, {
    downloadLink("downloadSample", "Download Sample of Dwellings")
  })
  
  
  
  #####################################
  # Generate Sample of Dwellings 
  #####################################
  observeEvent(input$generateSample, {
    req(input$cluster.id)
    
    SAMPLE_NUM<-8
    get_dwellings<-load_dwellings(input$cluster.id) 
    dwellings<-get_dwellings['dwellings']
    dwellings <- data.frame(Reduce(rbind, dwellings))
    
    dwellings_by_cluster<-dwellings%>%filter(cluster_id == input$cluster.id)
    check_cluster<-load_clusters() %>% filter(id == input$cluster.id)

    if(check_cluster$sample_taken==0){
    
      dwellings_by_cluster$sample.order<-sample(1:nrow(dwellings_by_cluster))
      dwellings_by_cluster$sampled<-ifelse(dwellings_by_cluster$sample.order<=SAMPLE_NUM,TRUE,FALSE)
      dwellings_by_cluster$replacement.order<-ifelse(dwellings_by_cluster$sampled==FALSE,dwellings_by_cluster$sample.order-SAMPLE_NUM,NA)
      dwellings_by_cluster<-dwellings_by_cluster%>%
        select(region_name_en, region_name_uk, dwelling_id, dwelling_number, sample.order, sampled, replacement.order, address) %>%
        arrange(sample.order)
      
      #update Dwellings
      
      update_dwellings(dwellings_by_cluster)
      
      #update cluster
      update_cluster(input$cluster.id)
      
      
      
    } else {
    
      dwellings_sampled <- dwellings_by_cluster %>% filter(sampled==1 | replacement_order_number <= 8)
      dwellings_sampled<-dwellings_sampled%>%
        select(region_name_en, region_name_uk, dwelling_id, dwelling_number, sampled, replacement_order_number, address) %>%
        arrange(replacement_order_number)
      
     
    }
    #create table  
    output$sampleTable<-make_datatable(dwellings_sampled)
    create_ckecklist(dwellings_by_cluster)
  })
  
  #create second table for the checklist
 create_ckecklist<-function(dwellings_by_cluster){
   
    dwellings_sampled <- dwellings_by_cluster %>% filter(sampled==1)
    dwellings_sampled$visited<-"[ ]"
    dwellings_sampled$int_completed<-"[ ]"
    dwellings_sampled$salt_collected<-"[ ]"
    dwellings_sampled$urine_1<-"[ ]"
    dwellings_sampled$urine_2<-"[ ]"
    
    dwellings_sampled<-dwellings_sampled%>%
      select(structure_number, dwelling_number, address, visited, int_completed, salt_collected, urine_1, urine_2) 
    dwellings_sampled[nrow(dwellings_sampled) + 1,] = c(" "," "," ","[ ]", "[ ]", "[ ]", "[ ]", "[ ]")
    dwellings_sampled[nrow(dwellings_sampled) + 1,] = c(" "," "," ","[ ]", "[ ]", "[ ]", "[ ]", "[ ]")
    output$checklistTable<-make_datatable(dwellings_sampled)
  }
  
  #####################################
  # Data table 
  #####################################
  
  output$sampleTable<-make_datatable(NULL)
  output$checklistTable<-make_datatable(NULL)

  #####################################
  # Sample Dwellings within a cluster
  #####################################

    # Function to download the sample for the chosen cluster as an Excel file
  output$downloadSample<- downloadHandler(
    
    filename = function() {
      paste(input$cluster.id,'-', Sys.Date(), '.xlsx', sep='')
    },
    
    
    content = function(con) {
      write.xlsx(sampleDwellings(), con,row.names=FALSE)
    }
  )

  ####################################
  # Initial Map Render
  ####################################
  output$mymap <- renderLeaflet({
    vals$base <-leaflet() %>% addTiles() %>% addProviderTiles("Esri.WorldStreetMap") %>%
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
    clusters_not_completed<-subset(clusters, cluster_completed == FALSE | is.na(cluster_completed))
    clusters_completed<-subset(clusters, cluster_completed == TRUE)

    ## Clear map
    leafletProxy("mymap") %>%
      clearShapes() %>%
      clearMarkers() %>%
      setView(lng = zoom_point$longitude, lat = zoom_point$latitude, zoom = zoom_point$zoom)

    ## render completed clusters if they exist
    if(nrow(clusters_completed) > 0) {

      cluster_shapes_completed<-subset(cluster_shapes, name %in% clusters_completed$id)
      info_cluster_completed<-subset(clusters_completed, id==cluster_shapes_completed$name)

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
    if(nrow(clusters_not_completed) > 0) {

      cluster_shapes_not_completed <- subset(cluster_shapes, name %in% clusters_not_completed$id)
      info_cluster_not_completed<-subset(clusters_not_completed, id %in% cluster_shapes_not_completed$name)


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

   updateSelectInput(session,
                     "cluster.id",
                     label = "Select Cluster ID for Sampling",
                     choices = clusters$id,
                     selected=clusters$id[clusters$id==selected_cluster['id']]
   )
   

   if(!is.null(selected_cluster)) {
      
    
      # building_file = paste0("Data/test/buildings_cluster", selected_cluster$id,".geojson")
      # building_points = readOGR(building_file)
  
      buildings <- load_buildings(selected_cluster["id"])
      combined_list <- load_dwellings(selected_cluster["id"])
      dwellings <- combined_list$dwellings
      dwellings_per_building <- combined_list$dwellings_per_building
      
      
      buildings <- left_join(buildings, dwellings_per_building, by="structure_number")
      
      
      browser()
      
      
      leafletProxy("mymap") %>%
        setView(lng = selected_cluster["lng"], lat = selected_cluster["lat"], zoom = 13) %>%
        clearMarkers() %>%
        addCircleMarkers(data = buildings, 
                          lng = buildings$longitude,
                          lat = buildings$latitude,
                          radius = 5,
                          stroke = FALSE,
                          color = "blue",
                          popup = paste("<h5>Building number ", buildings$structure_number
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

  #####################################
  # QR CODE STUFF
  #####################################
  qrcode = reactive( t(qrcode_gen("https://stats4sd.org", plotQRcode= FALSE, dataOutput = TRUE)))
  nc = reactive( ncol(qrcode()))
  nr = reactive( nrow(qrcode()))
  scale = 10
  
  output$qrtest <- renderPlot({
    par(mar=c(0,0,0,0))
    image(
      1L:nc(),
      1L:nr(),
      qrcode(),
      xlim = 0.5 + c(0, nc()),
      ylim = 0.5 + c(nr(), 0),
      axes = FALSE,
      xlab = "",
      ylab = "",
      col = c("white", "black"),
      asp = 1
      )
    }, width = function() scale*nc(), height = function() scale*nr())
  
  #####################################
  # Download Map
  #####################################
  
  # reactive values to store map
  vals <- reactiveValues()
  
  
  
  # create map as viewed by user
  observeEvent({
    input$mymap_zoom
    input$mymap_center
  }, {
    vals$current <- vals$base %>% 
      setView(lng = input$mymap_center$lng,
              lat = input$mymap_center$lat,
              zoom = input$mymap_zoom)
  }
  )
  
  # create download
  output$dl <- downloadHandler(
    filename = "map.png",
    
    content = function(file) {
      mapshot(vals$current, file = file,
              # 2. specify size of map based on div size
              vwidth = input$dimension[1], vheight = input$dimension[2])
    }
  )
}