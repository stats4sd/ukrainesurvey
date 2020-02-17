
####################################
# Show Modal to confirm building listing is complete
####################################
dataModal <- function() {
  modalDialog(
    h4(class="text-warning", "WARNING"),
    p("You are about to generate the sample for this cluster. Once done, you will not be able to add additional buildings or dwellings to this cluster."),
    p("Please confirm that building listing is complete to continue."),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_sample", "I confirm building listing is complete", class = "btn-success", )
    )
  )
}



#####################################
# Generate Sample of Dwellings 
#####################################
generate_sample <- function() {
  
  req(input$cluster)
  
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

#create second table for the checklist
create_ckecklist<-function(dwellings_sampled){
  
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
