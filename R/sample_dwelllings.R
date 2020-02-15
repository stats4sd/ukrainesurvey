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

#####################################
# Generate Sample of Dwellings 
#####################################
observeEvent(input$generateSample, {
  req(input$cluster.id)
  
  SAMPLE_NUM<-8
  dwellings<-load_dwellings(input$cluster.id) 
  
  dwellings_by_cluster<-dwellings%>%filter(cluster_id == input$cluster.id)
  check_cluster<-load_clusters() %>% filter(id == input$cluster.id)
  
  if(check_cluster$sample_taken==0){
    
    dwellings_by_cluster$sample.order<-sample(1:nrow(dwellings_by_cluster))
    dwellings_by_cluster$sampled<-ifelse(dwellings_by_cluster$sample.order<=SAMPLE_NUM,TRUE,FALSE)
    dwellings_by_cluster$replacement.order<-ifelse(dwellings_by_cluster$sampled==FALSE,dwellings_by_cluster$sample.order-SAMPLE_NUM,NA)
    dwellings_by_cluster<-dwellings_by_cluster%>%
      arrange(sample.order)
    
    #update Dwellings
    
    update_dwellings(dwellings_by_cluster)
    
    #update cluster
    update_cluster(input$cluster.id)
    
    
    
  } else {
    
    dwellings_sampled <- dwellings_by_cluster %>% filter(sampled==1 | replacement_order_number <= 8)
    dwellings_sampled<-dwellings_sampled%>%
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
