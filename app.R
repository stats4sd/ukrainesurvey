library(shiny)
library(leaflet)
library(shinythemes)
library(mapview)



# Define UI for app that draws a histogram ----
ui <- fluidPage(theme = shinytheme("cerulean"),
 
  navbarPage("Ukraine",  
             tabPanel("Field work support",
                      #Start 'Field work support' tab
                      
                      p('This section is for support people in Ukraine'),
                      
                      column(4,
                      selectizeInput("region",
                                     "Filter by Region",
                                     regions,
                                     options = list(
                                       placeholder = "Select a region",
                                       onInitialize = I('function() { this.setValue(""); }')
                                     )
                      ), 
                      selectInput("cluster.id", 
                                  label = "Select Cluster ID for Sampling", 
                                  choices = c(2424,34234,34234234,234,2342,34,423,423,42,3)
                      ),
                      downloadButton("downloadSample", "Download sample", class = "btn-primary"),
                      
                      downloadButton("downloadCheckList", "Download checklist", class = "btn-primary"),
                      
                      
                      ),
                      
                      column(8,
                             
                      leafletOutput("map", height="85vh"),
                      downloadButton("downloadMap", "Download map", class = "btn-primary")
                      )
                      #end 'Field work support'
                      ),
             
             
             
             tabPanel("Summary"),
                     #Start 'Summary' tab
              
                     p("What info do you want?"),
                    
                    #end 'Summary'
             tabPanel("Manager's platform")
             ),
  
  
  

)

# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
  
  # Create the map
  output$map <- renderLeaflet({
    m<-leaflet() %>% addTiles() %>% addProviderTiles("Esri.WorldStreetMap")
  })
  output$downloadMap <- downloadHandler(
    filename = "map.png",
    
    content = function(file){
      mapshot(m, url=file)
    
    } # end of content() function
  ) # end of downloadHandler() function
  
  
} #end server


shinyApp(ui = ui, server = server)
