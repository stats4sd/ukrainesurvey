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
# @returns sampled dwellings
#####################################
generate_new_sample <- function(cluster_id, dwellings) {

    SAMPLE_NUM<-8
  check_cluster<-load_clusters() %>% filter(id == cluster_id)
  
  if(check_cluster$sample_taken==0){
   
    dwellings$sample.order<-sample(1:nrow(dwellings))
    dwellings$sampled<-ifelse(dwellings$sample.order<=SAMPLE_NUM,TRUE,FALSE)
    dwellings$salt_needed <- ifelse(dwellings$sample.order %in% list(1, 2, 4, 6, 8),TRUE,FALSE)

    #update Dwellings in database
    update_dwellings(dwellings)
    
    #update cluster in database
    update_cluster(cluster_id)
    
  }
  dwellings_sampled <- dwellings %>% filter(sampled == 1)  
  
  dwellings_sampled$visited<-"[ ]"
  dwellings_sampled$int_completed<-"[ ]"
  dwellings_sampled$salt_collected<-"[ ]"
  dwellings_sampled$urine_1<-"[ ]"
  dwellings_sampled$urine_2<-"[ ]"
  
  dwellings_sampled<-dwellings_sampled %>%
    select(structure_number, dwelling_number, address, visited, int_completed, salt_collected, urine_1, urine_2)
  
  return(dwellings_sampled)

}

#####################################
# Function to build a downloadable datatable with the sampled dwellings
# @prop cluster_id - the id of the cluster to download sample for
# @prop dwellings_sampled - only the sampled dwellings for the current cluster.
#####################################
download_sample <- function(cluster_id, dwellings_sampled){

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

#####################################
# Function to generate replacement for a cluster
# @prop cluster_id - the id of the cluster to sample
# @returns the list of replaced dwellings or NULL if the sample was not taken.
#####################################
generate_replacement <- function(cluster_id, repl_num) {

  repl_num <-as.numeric(repl_num)
 
  dwellings <- load_dwellings(cluster_id)
  check_cluster <- load_clusters() %>% filter(id == cluster_id)
  check_replacement <- dwellings %>%  filter(replacement_order_number == max(replacement_order_number, na.rm = TRUE))
  
  #Create the last replacement number 
  if(nrow(check_replacement)>0){
    
    last_repl_num<-as.numeric(max(check_replacement$replacement_order_number,  na.rm = TRUE))
    
  } else {
    
    last_repl_num<-0
  }
  
  if(check_cluster$sample_taken == 1){

    dwellings_not_sampled <- dwellings %>%  subset(sampled==FALSE & is.na(replacement_order_number))
    selected_replacement <- sample_n(dwellings_not_sampled, size=repl_num, replace = FALSE)
    selected_replacement$replacement_order_number <- last_repl_num+1:nrow(selected_replacement)
    
    #update Dwellings in database
    update_replacement(selected_replacement)
    
    #create replaced_dwellings for the return
    dwellings <- load_dwellings(cluster_id)
    replaced_dwellings<-dwellings%>%  filter(replacement_order_number <= last_repl_num + repl_num)
    replaced_dwellings <- replaced_dwellings %>% select(replacement_order_number, region_name_uk, region_name_en, cluster_id, structure_number, address ,latitude,longitude)
    replaced_dwellings<-replaced_dwellings[order(replaced_dwellings$replacement_order_number),]
    return(replaced_dwellings)
  
  } else {
    
    return(NULL) 
  }
  
}

#####################################
# Function to count replacement for a cluster
# @prop cluster_id - the id of the cluster to sample
# @return a number of replacement for the cluster
#####################################
count_replacement <- function(cluster_id) {
  
  dwellings_by_cluster<-load_dwellings(cluster_id)
  number_replacement<-length(which(dwellings_by_cluster$replacement_order_number>0))
  return(number_replacement)
  
}

#####################################
# Function to count replacement for a cluster
# @prop cluster_id - the id of the cluster to sample
# @return a number of replacement for the cluster
#####################################
replacement_list <- function(cluster_id) {
  
  dwellings_by_cluster<-load_dwellings(cluster_id)
  replaced_dwellings <- dwellings_by_cluster %>%  filter(replacement_order_number > 0)
  replaced_dwellings <- replaced_dwellings %>% select(replacement_order_number, region_name_uk, region_name_en, cluster_id, structure_number, address ,latitude,longitude)
  
  return(replaced_dwellings)
  
}


