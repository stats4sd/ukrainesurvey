library(dplyr)
library(RMySQL)

#####################################
# Generates new sample for chosen cluster
#####################################
generate_sample<-function(dwellings, cluster.id=NULL){

  dwellings_sample<-df%>%
    filter(cluster_id==cluster.id)
    
  dwellings_sample$sample.order<-sample(1:nrow(dwellings_sample))
  
  dwellings_sample$sampled<-ifelse(dwellings_sample$sample.order<=16,TRUE,FALSE)
  
  dwellings_sample$replacement.order<-ifelse(dwellings_sample$sampled==FALSE,dwellings_sample$sample.order-16,NA)
  
  dwellings_sample<-dwellings_sample%>%
    select(region_name_en, region_name_uk, structure_number, dwelling_id, dwelling_number, sample.order, sampled, replacement.order, address) %>%
    arrange(sample.order)
  
  dwellings_download<<-data.frame(dwellings)
}


sampleDwellings<-reactive({
  sampleDwellings<-data.frame(generate_sample(dwellings, input$cluster.id))
})

# Function to download the sample for the chosen cluster as an Excel file
output$downloadSample<- downloadHandler(
  
  filename = function() {
    paste(input$cluster.id,'-', Sys.Date(), '.xlsx', sep='')
  },
  
  
  content = function(con) {
    write.xlsx(sampleDwellings(), con,row.names=FALSE)
  }
)