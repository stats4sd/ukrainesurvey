server <- function(input, output, session) {

  #####################################
  # Generate Sample of Dwellings 
  #####################################
  observeEvent(input$confirm_sample, {
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
  
  observeEvent(input$generate_sample_button, {
    showModal(dataModal())
  })
  
  observeEvent(input$confirm_sample, {
    removeModal()
    generate_sample(input$cluster)
  })
  
  
  ## Something to do with the cluster summary tab...
  reactive({
    
   if(!is.na(input$summary_cluster)){
    
     sum_clusters<-subset(summary_clusters, cluster_id=input$summary_cluster)
   } else {
     sum_clusters<-load_clusters(clusters$id[1])
     
   }
    
  })
  
  ####################################
  # Initial Map Render
  ####################################
  output$mymap <- renderLeaflet({
    vals$base <-leaflet() %>% addTiles() %>%
      addKML(country_shape, fillOpacity = 0) %>%
      addMiniMap(
        toggleDisplay = TRUE
      )       
    })
                         
  ####################################
  # Render Clusters based on Status                                                                                                                                                    
  ####################################                                            
  
  observeEvent(input$region, {
    
    if( !is.na(input$region) & input$region != "") {
      region_clusters <- subset(clusters, region_id == input$region)
    }
    else {
      region_clusters <- clusters
    }
    
    updateSelectInput(session,
                      "cluster",
                      choices = region_clusters$id
    )
    
    leafletProxy("mymap") %>%
      clearShapes() %>%
      clearMarkers()
    
    cluster_shapes <- subset(shape_json, name %in% region_clusters$id)
    
    leafletProxy("mymap") %>%
      addPolygons(layerId = cluster_shapes$name,
                  data = cluster_shapes ,
                  weight = 1,
                  fillColor = region_clusters$status_colour,
                  highlightOptions = highlightOptions(color = "blue", weight = 3,
                                                      bringToFront = TRUE)
      ) 
    
    ## Other Region-selection stuff
    selected_region <<- subset(regions, id==input$region)
    
    output$region_name <- renderText(selected_region$name_en)
    
    zoom_point <- zoom_to()
    
    leafletProxy("mymap") %>%
      setView(lng = zoom_point$longitude, lat = zoom_point$latitude, zoom = zoom_point$zoom)  
    
  }) #end render clusters
  
  
  
  ####################################
  # When Region Is Selected
  ####################################
  
  ## zoom to region
  zoom_to <- reactive({
    if(input$region==""){
      return(data.frame(longitude = 31.165580, latitude = 48.379433, zoom = 6))
    }else{
      return(select(filter(regions, id == input$region), c(longitude,latitude,zoom)))
    }
  })


  ####################################
  # When Cluster Is Selected
  ####################################

  ## via the map (update select input)
  observeEvent(input$mymap_shape_click, {
    
    # here, we only update the select input. This triggers the observe(input$cluster) code block, which does all the interesting stuff.
    updateSelectInput(session,
                     "cluster",
                     choices = clusters$id,
                     selected=clusters$id[clusters$id==input$mymap_shape_click['id']]
    )
    
  })
  
  # via the select input directly
  observeEvent(input$cluster, {
    
    # if input$cluster is empty, end here... 
    req(input$cluster)
    
    
    selected_cluster <<- subset(clusters, id == input$cluster)
    selected_cluster_shape <-  subset(shape_json, name == selected_cluster$id)
    output$cluster_name <- renderText(selected_cluster$id)
    
    if( selected_cluster$sample_taken == 0 ) {
      shinyjs::hide('sample_taken')
      shinyjs::show('sample_not_taken')
    }
    else {
      shinyjs::hide('sample_not_taken')
      shinyjs::show('sample_taken')    
    }
    
    # Only update region if region is not already set correctly
    if( input$region != clusters$region_id[clusters$id == selected_cluster$id] ) {
      
      browser()
      
      updateSelectInput(session,
                        "region",
                        choices = regions_list,
                        selected = clusters$region_id[clusters$id == selected_cluster$id])
      
      output$region_name <- renderText(clusters$region_name_en[clusters$id==selected_cluster$id])
      
    }
    

    buildings <<- load_buildings(selected_cluster$id)
    dwellings <<- load_dwellings(selected_cluster$id)
    
    # setup labels for buildings
    
    building_labels <- lapply(seq(nrow(buildings)), function(i) {
      paste0( 
        "<h5>Structure No. ", buildings[i, "structure_number"], "</h5>",
        "<b>Address:</b>", buildings[i, "address"], "<br/>"
      )
    })

    leafletProxy("mymap") %>%
      setView(lng = selected_cluster$longitude, lat = selected_cluster$latitude, zoom = 13) %>%
      clearMarkers() %>%
      addCircleMarkers(data = buildings, 
                       lng = buildings$longitude,
                       lat = buildings$latitude,
                       radius = 5,
                       stroke = FALSE,
                       color = "blue",
                       label = lapply(building_labels, htmltools::HTML)
                       # labelOptions = labelOptions(
                       #   noHide = T,
                       # )
      ) %>%
      
      # add highlight to current cluster
      addPolygons(layerId = "selected_cluster",
                  data = selected_cluster_shape ,
                  weight = 5,
                  color = "blue",
                  fillColor = selected_cluster$status_colour
      )
    

    

    output$cluster_info <- renderUI({
      HTML(paste0(
        "<b>Region: </b>", selected_cluster$region_name_en, "</br>",
        "<h5><strong>Cluster ID: ", selected_cluster$id, "</strong></h5>",
        "<hr/>",
        "<h6 class='text-", selected_cluster$status_colour, "'><b>STATUS: </b>", selected_cluster$status_text, "</h6>",
        "<hr/>",
        "<b>No. of Buildings: </b>", selected_cluster$tot_buildings,"</br>",
        "<b>No. of Dwellings: </b>",selected_cluster$tot_dwellings,"</br>"      
        ))
    })    
       
     
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

  }) #endobserve

  #####################################
  # QR CODE STUFF
  #####################################
  # qrcode = reactive( t(qrcode_gen("https://stats4sd.org", plotQRcode= FALSE, dataOutput = TRUE)))
  # nc = reactive( ncol(qrcode()))
  # nr = reactive( nrow(qrcode()))
  # scale = 10
  
  # output$qrtest <- renderPlot({
  #   par(mar=c(0,0,0,0))
  #   image(
  #     1L:nc(),
  #     1L:nr(),
  #     qrcode(),
  #     xlim = 0.5 + c(0, nc()),
  #     ylim = 0.5 + c(nr(), 0),
  #     axes = FALSE,
  #     xlab = "",
  #     ylab = "",
  #     col = c("white", "black"),
  #     asp = 1
  #     )
  #   }, width = function() scale*nc(), height = function() scale*nr())
  
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