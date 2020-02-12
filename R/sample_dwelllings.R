library(dplyr)
library(RMySQL)

#####################################
# Generates new sample for chosen cluster
#####################################
generate_sample<-function(dwellings, cluster.id=NULL){
  
  SAMPLE_NUM<-8
 
  dwellings_sample<-df%>%
    filter(cluster_id==cluster.id)
    
  dwellings_sample$sample.order<-sample(1:nrow(dwellings_sample))
  
  dwellings_sample$sampled<-ifelse(dwellings_sample$sample.order<=SAMPLE_NUM,TRUE,FALSE)
  
  dwellings_sample$replacement.order<-ifelse(dwellings_sample$sampled==FALSE,dwellings_sample$sample.order-SAMPLE_NUM,NA)
  
  dwellings_sample<-dwellings_sample%>%
    select(region_name_en, region_name_uk, structure_number, dwelling_id, dwelling_number, sample.order, sampled, replacement.order, address) %>%
    arrange(sample.order)
  
  dwellings_download<<-data.frame(dwellings)
}

sampleDwellings<-reactive({
  sampleDwellings<-data.frame(generate_sample(dwellings, input$cluster.id))
})

