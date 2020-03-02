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
      actionButton("confirm_sample", "I confirm building listing is complete", class = "btn-success" )
    )
  )
}

#####################################
# Show sampled dwellings table for download / export
#####################################
dataTableModal <- function(cluster_id) {
  modalDialog(
    size = 'l',
    h4(class="text-success", paste("Sampled Dwellings for Cluster - ", cluster_id)),
    p("The table below shows the 8 sampled dwellings for this cluster, and 2 empty rows to be used for replacements if needed."),
    p("Please download this as a pdf file and print it for field use."),
    DT::dataTableOutput("checklistTable"),
    
    footer = tagList(
      modalButton("Close")
    )
  )
}

#####################################
# Show modal if too few dwellings to take sample
#####################################
too_few_dwellings_modal <- function() {
  modalDialog(
    h4(class = "text-warning", "NO SAMPLE HAS BEEN TAKEN"),
    h5(class = "text-warning", "There are too few dwellings in this cluster to take a sample. Please double check the building listing data, and ensure that every occupied building in the cluster is accounted for."),
    footer = tagList(
      modalButton("Return to dashboard")
    )
  )
}

#####################################
# Function to generate a sample for a cluster
# @prop cluster_id - the id of the cluster to sample
# @prop dwellings - passing the global dwellings into the variable (probably not needed because globals... 
# @returns null - calls function to download sample.
#####################################
generate_new_sample <- function(cluster_id, dwellings) {
  
  SAMPLE_NUM<-8
  check_cluster<-load_clusters() %>% filter(id == cluster_id)
  
  if(check_cluster$sample_taken==0){
    
    dwellings$sample.order<-sample(1:nrow(dwellings))
    dwellings$sampled<-ifelse(dwellings$sample.order<=SAMPLE_NUM,TRUE,FALSE)
    dwellings$salt_needed <- ifelse(dwellings$sample.order %in% list(1, 2, 4, 6, 8),TRUE,FALSE)
      
    dwellings$replacement_order_number<-ifelse(dwellings$sampled==FALSE,dwellings$sample.order-SAMPLE_NUM,NA)
    
    # update global variable
    dwellings<-dwellings%>%
      arrange(sample.order)
    
    #update Dwellings in database
    update_dwellings(dwellings)
    
    #update cluster in database
    update_cluster(cluster_id)
    
  }
  
  return(dwellings)

}



#####################################
# Function to build a downloadable datatable with the sampled dwellings
# @prop cluster_id - the id of the cluster to download sample for
# @prop dwellings_sampled - only the sampled dwellings for the current cluster.
#####################################
download_sample <- function(cluster_id, dwellings_sampled){
  
  dwellings_sampled <- dwellings_sampled %>% 
    filter(sampled == 1)
  
  dwellings_sampled$visited<-"[ ]"
  dwellings_sampled$int_completed<-"[ ]"
  dwellings_sampled$salt_collected<-"[ ]"
  dwellings_sampled$urine_1<-"[ ]"
  dwellings_sampled$urine_2<-"[ ]"
  
  dwellings_sampled<-dwellings_sampled %>%
    select(structure_number, dwelling_number, address, visited, int_completed, salt_collected, urine_1, urine_2)
  
  dwellings_sampled[nrow(dwellings_sampled) + 1,] = c(" "," "," ","[ ]", "[ ]", "[ ]", "[ ]", "[ ]")
  dwellings_sampled[nrow(dwellings_sampled) + 1,] = c(" "," "," ","[ ]", "[ ]", "[ ]", "[ ]", "[ ]")
  
  showModal(dataTableModal(cluster_id))
  
  return(make_sample_datatable(dwellings_sampled))
  
}
