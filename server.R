server <- function(input, output, session) {

  #####################################
  # Generate Sample of Dwellings 
  #####################################
  get_sample <- reactive({
    list(input$confirm_sample, input$download_sample)
  })
  
  observeEvent(get_sample(), {
    removeModal()
    
    req(input$cluster)
    
    if(is.data.frame(dwellings) && nrow(dwellings) <= 18 ) {
      showModal(too_few_dwellings_modal())
    }
  
    else {
      
      SAMPLE_NUM<-8
      check_cluster<-load_clusters() %>% filter(id == input$cluster)
      
      if(check_cluster$sample_taken==0){
        
        dwellings$sample.order<-sample(1:nrow(dwellings))
        dwellings$sampled<-ifelse(dwellings$sample.order<=SAMPLE_NUM,TRUE,FALSE)
        dwellings$replacement_order_number<-ifelse(dwellings$sampled==FALSE,dwellings$sample.order-SAMPLE_NUM,NA)
        dwellings<-dwellings%>%
          arrange(sample.order)
        
        #update Dwellings in database
        update_dwellings(dwellings)
        
        #update cluster in database
        update_cluster(input$cluster)
        
      }
      
      dwellings_sampled <- dwellings %>% filter(sampled==1 | replacement_order_number <= 10)
      dwellings_sampled<-dwellings_sampled%>%
        arrange(replacement_order_number)
      
      #create table  
      output$sampleTable<-make_datatable(dwellings_sampled)
      create_ckecklist(dwellings_sampled)
    }
    
    
    
    
    
  })
  
  #create second table for the checklist
  create_ckecklist<-function(dwellings_sampled){
    
    dwellings_sampled$visited<-"[___]"
    dwellings_sampled$int_completed<-"[ ]"
    dwellings_sampled$salt_collected<-"[ ]"
    dwellings_sampled$urine_1<-"[ ]"
    dwellings_sampled$urine_2<-"[ ]"
    
    dwellings_sampled<-dwellings_sampled%>%
      filter(sampled==1) %>%
      select(structure_number, dwelling_number, address, visited, int_completed, salt_collected, urine_1, urine_2)
     
    dwellings_sampled[nrow(dwellings_sampled) + 1,] = c(" "," "," ","[ ]", "[ ]", "[ ]", "[ ]", "[ ]")
    dwellings_sampled[nrow(dwellings_sampled) + 1,] = c(" "," "," ","[ ]", "[ ]", "[ ]", "[ ]", "[ ]")
    
    showModal(dataTableModal())
    
    output$checklistTable<-make_sample_datatable(dwellings_sampled)
    
  }
  
  observeEvent(input$generate_sample_button, {
    showModal(dataModal())
  })
  
  ## Something to do with the cluster summary tab...
  
  
  ####################################
  # Initial Map Render
  ####################################
  
  output$mymap <- renderLeaflet({
    vals$base <-leaflet() %>% addTiles() %>%
      addKML(country_shape, fillOpacity = 0) %>%
      addMiniMap(
        toggleDisplay = TRUE
      ) %>% 
      onRender(
        "function(el, x) {
            L.easyPrint({
              sizeModes: ['A4Landscape', 'A4Portrait'],
              filename: 'mymap',
              exportOnly: true,
              hideControlContainer: true
            }).addTo(this);
            }"
      )
    })

  output$sampleTable<-make_datatable(NULL)
  output$checklistTable<-make_datatable(NULL)
  
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
    cluster_shapes <- merge(cluster_shapes, region_clusters, by.x = "name", by.y = "id")
    
    leafletProxy("mymap") %>%
      addPolygons(layerId = cluster_shapes$name,
                  data = cluster_shapes ,
                  weight = 1,
                  opacity = 0.5,
                  fillColor = cluster_shapes$status_colour,
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
      

      updateSelectInput(session,
                        "region",
                        choices = regions_list,
                        selected = clusters$region_id[clusters$id == selected_cluster$id])
      
      output$region_name <- renderText(clusters$region_name_en[clusters$id==selected_cluster$id])
      
    }
    
    #####################################
    # Handle Building Markers
    #####################################
    
    # set buildings and dwellings to the global vars, so we only need to call the db once when the cluster loads.
    buildings <<- load_buildings(selected_cluster$id)
    dwellings <<- load_dwellings(selected_cluster$id)
    
    
    # setup labels for buildings
    building_labels <- lapply(seq(nrow(buildings)), function(i) {
      
      paste0( 
        "<h5>Structure No. ", buildings[i, "structure_number"], "</h5>",
        "<b>Address:</b>", buildings[i, "address"], "<br/>",
        "<b>No. of Dwellings </b>", buildings[i, "num_dwellings"], "<br/>",
        "<a href='https://maps.google.com/?q=",buildings[i, "latitudine"],",",buildings[i,"longitude"],"'",">Open Google Maps<a/>"
      )
     })
    
    leafletProxy("mymap") %>%
      setView(lng = selected_cluster$longitude, lat = selected_cluster$latitude, zoom = 13) %>%
      clearMarkers() %>%
      # add highlight to current cluster
      addPolygons(layerId = "selected_cluster",
                  data = selected_cluster_shape ,
                  weight = 5,
                  color = "blue",
                  opacity = "0.5",
                  fillColor = selected_cluster$status_colour
      ) %>%
      # Add building markers
      addCircleMarkers(data = buildings, 
                       lng = buildings$longitude,
                       lat = buildings$latitude,
                       radius = 5,
                       stroke = FALSE,
                       fillOpacity = 1,
                       color = buildings$status_colour,
                       popup = lapply(building_labels, htmltools::HTML)
                       
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
  
 
}