server <- function(input, output, session) {

  # initialise some variables
  selected_region <- NULL
  selected_cluster <- NULL
  buildings <- NULL
  dwellings <- NULL
  



  output$clustersTable <- make_datatable(cluster_summary)
  output$districtsTable <- make_datatable(district_summary)
  output$oblastsTable <- make_datatable(oblast_summary)
  output$nationalTable <- make_datatable(national_summary)

<<<<<<< HEAD
<<<<<<< Updated upstream
=======
  # prepare printable download
  output$testdown <- downloadHandler(
    filename = function() {
      paste0("Testing Download.pdf")
    },
    
    content = function(file) {
      
      tempReport <- file.path(tempdir(), "sampled_dwellings.Rmd")
      file.copy("sampled_dwellings.Rmd", tempReport, overwrite = TRUE)
      
      params <- list(
        clusters = clusters
        )
      
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
  
>>>>>>> Stashed changes
=======
    
>>>>>>> dev
  shinyjs::hide('error_message')
  shinyjs::hide('replament_table')
  shinyjs::hide('show_replacement')
  shinyjs::hide('generate_replacement')
  #####################################
  # Generate Sample of Dwellings
  #####################################
  observeEvent(input$confirm_sample, {
    req(input$cluster)

    if(is.data.frame(dwellings) && nrow(dwellings) <= 18 ) {
      showModal(too_few_dwellings_modal())
    }
    else {
      dwellings_sampled <- generate_new_sample(input$cluster, dwellings)
      output$checklistTable <- download_sample(input$cluster, dwellings_sampled)


      ## manually update values to avoid need for reloading from database;
      clusters$status_colour[clusters$id == input$cluster] <<- "blue"
      clusters$status_text[clusters$id == input$cluster] <<- "data collection in progress"
      clusters$sample_taken[clusters$id == input$cluster] <<- 1

      # update region select to prompt re-rendering of cluster shapes
      cluster_shapes <- subset(shape_json, name %in% input$cluster)
      cluster_shapes <- merge(cluster_shapes, clusters, by.x = "name", by.y = "id")

      leafletProxy("mymap") %>%
      addPolygons(layerId = input$cluster,
                  data = cluster_shapes ,
                  weight = 1,
                  opacity = 0.5,
                  fillColor = cluster_shapes$status_colour,
                  highlightOptions = highlightOptions(color = "blue", weight = 3,
                                                      bringToFront = TRUE)
      )

      # update cluster select to prompt re-rendering of building dots.
      updateSelectInput(session,
                        "cluster",
                        choices = subset(clusters, region_id == input$region)$id,
                        selected=clusters$id[clusters$id == input$cluster]
      )
    }
<<<<<<< HEAD
<<<<<<< Updated upstream

=======
    
    showModal(dataTableModal(input$cluster))
    
    # prepare printable download
    output$sample_downloader <- downloadHandler(
      filename = function() {
         paste0("Sampled Dwellings for cluster ", clusters$id, ".pdf")
      },

      content = function(file) {
        
        tempReport <- file.path(tempdir(), "sampled_dwellings.Rmd")
        file.copy("sampled_dwellings.Rmd", tempReport, overwrite = TRUE)
        
        params <- list(
          selected_cluster = input$cluster, 
          sampled_dwellings = dwellings_sampled)
        
        rmarkdown::render(tempReport, output_file = file,
                          params = params,
                          envir = new.env(parent = globalenv())
        )
      }
    )
>>>>>>> Stashed changes
=======
    
>>>>>>> dev
  })

  observeEvent(input$download_sample, {
    req(input$cluster)
    dwellings<-load_dwellings(input$cluster)
    output$checklistTable <- download_sample(input$cluster, dwellings)
  })

  observeEvent(input$generate_sample_button, {
    showModal(dataModal())
  })

  ## Something to do with the cluster summary tab...


  ####################################
  # Initial Map Render
  ####################################

  cluster_filename <- reactive({
    if(!is.na(input$cluster) & input$cluster != "") {
      return(paste0("-cluster-", input$cluster))  
    }
    return("")
  })
  
  map_reactive <- reactive({
    leaflet() %>%
      addTiles() %>%
      addKML(country_shape, fillOpacity = 0) %>%
      addMiniMap(
        toggleDisplay = TRUE

      ) %>%
      onRender(
        paste0("function(el, x) {
              L.easyPrint({
                sizeModes: ['A4Landscape', 'A4Portrait'],
                filename: 'iodine-survey-map",cluster_filename(),"',
                exportOnly: true,
                hideControlContainer: true
              }).addTo(this);
              }"
        )
      )
    })

  output$mymap <- renderLeaflet({
    map_reactive()
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

    
    browser() 
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

    progress<- shiny::Progress$new()
    on.exit(progress$close())

    progress$set(message = "getting cluster details", value = 0)

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
    progress$inc(1/3, detail = "loading buildings")
    buildings <<- load_buildings(selected_cluster$id)


    progress$inc(2/3, detail = "loading dwellings")
    dwellings <<- load_dwellings(selected_cluster$id)


    # setup labels for buildings
    building_labels <- lapply(seq(nrow(buildings)), function(i) {

      paste0(
        "<h5>Structure No. ", buildings[i, "structure_number"], "</h5>",
        "<b>Address:</b>", buildings[i, "address"], "<br/>",
        "<b>No. of Dwellings </b>", buildings[i, "num_dwellings"], "<br/>",
        "<a href='https://maps.google.com/?q=", buildings[i, "latitude"],",", buildings[i,"longitude"],"'",">Open Google Maps</a>"
      )
     })

    leafletProxy("mymap") %>%
      setView(lng = selected_cluster$longitude, lat = selected_cluster$latitude, zoom = 12) %>%
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
  # Generate replacement sample
  #####################################

  observeEvent(input$generate_replacement,{

    req(input$repl_cluster)
    req(input$repl_num)

    gener_repl_data<-generate_replacement(input$repl_cluster, input$repl_num)
    if(length(gener_repl_data)>0){
      shinyjs::hide('error_message')
      shinyjs::show('replament_table')
      output$replacementTable <- make_datatable(gener_repl_data)
    }else {
      shinyjs::show('error_message')
      shinyjs::hide('replament_table')
      output$message_error <- renderText({
        paste("the sample for the cluster", input$repl_cluster, "was not taken.")
      })
    }

  })

  #####################################
  # Update the current number of replacement
  #####################################

  observeEvent(input$generate_replacement,{
    number_replacement_db <- count_replacement(input$repl_cluster)
    output$replacement_number <- renderText({
      paste("Current number of replacement", number_replacement_db , ".")
    })
  })

  observeEvent(input$repl_cluster,{
    req(input$repl_cluster)
    number_replacement_db <- count_replacement(input$repl_cluster)
    output$replacement_number <- renderText({
      paste("Current number of replacement", number_replacement_db , ".")
    })
  })

  #####################################
  # Show replacement sample in database
  #####################################

  observe({
    req(input$repl_cluster)
    shinyjs::show('show_replacement')
    shinyjs::show('generate_replacement')
    number_replacement_db <- count_replacement(input$repl_cluster)
    if(number_replacement_db > 0){
      output$replacementTable <- make_datatable(replacement_list(input$repl_cluster))
      shinyjs::show('replament_table')
    }
  })

  #####################################
  # Cluster Summary
  #####################################

  observeEvent(input$filter_oblast_cs, {

    region_clusters <- subset(clusters, region_id == input$filter_oblast_cs)

    req(input$filter_oblast_cs)
    clus_summ <- replace(cluster_summary,is.na(cluster_summary),0)
    clus_summ <- subset(clus_summ, region_id %in% input$filter_oblast_cs)
    output$clustersTable <- make_datatable(clus_summ)

    updateSelectInput(session,
                      "filter_cluster_cs",
                      choices = region_clusters$id
    )

  })

  observeEvent(input$filter_cluster_summary, {
    req(input$filter_cluster_summary)

    clus_summ <- replace(cluster_summary,is.na(cluster_summary),0)
    clus_summ <- subset(clus_summ, cluster_id %in% input$filter_cluster_summary)
    output$clustersTable <- make_datatable(clus_summ)
  })

  #####################################
  # Oblast Summary
  #####################################

  observeEvent(input$filter_oblast_os, {

    oblast_summ <- replace(oblast_summary, is.na(oblast_summary),0)
    oblast_summ <- subset(oblast_summ, region_id %in% input$filter_oblast_os)
    output$oblastsTable <- make_datatable(oblast_summ)

  })

  #####################################
  # District Summary
  #####################################

  observeEvent(input$filter_oblast_ds, {

    region_clusters <- subset(clusters, region_id == input$filter_oblast_cs)

    req(input$filter_oblast_cs)
    clus_summ <- replace(cluster_summary,is.na(cluster_summary),0)
    clus_summ <- subset(clus_summ, region_id %in% input$filter_oblast_cs)
    output$districtsTable <- make_datatable(clus_summ)

    updateSelectInput(session,
                      "filter_district_ds",
                      choices = region_clusters$id
    )

  })

  observeEvent(input$filter_district_ds, {

    req(input$filter_district_ds)
    district_summ<- replace(district_summary,is.na(district_summary),0)
    district_summ <- subset(district_summ, district_id %in% input$filter_district_ds)
    output$districtsTable <- make_datatable(district_summ)
  })

  #####################################
  # National Summary
  #####################################

  ####


}