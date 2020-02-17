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
dataTableModal <- function() {
  modalDialog(
    size = 'l',
    h4(class="text-success", paste("Sampled Dwellings for Cluster - ", selected_cluster$id)),
    p("The table below shows the 8 sampled dwellings for this cluster, and 2 empty rows to be used for replacements if needed."),
    p("Please download this as a pdf file and print it for field use."),
    DT::dataTableOutput("checklistTable"),
    
    footer = tagList(
      modalButton("Close")
    )
  )
}

too_few_dwellings_modal <- function() {
  modalDialog(
    h4(class = "text-warning", "NO SAMPLE HAS BEEN TAKEN"),
    h5(class = "text-warning", "There are too few dwellings in this cluster to take a sample. Please double check the building listing data, and ensure that every occupied building in the cluster is accounted for."),
    footer = tagList(
      modalButton("Return to dashboard")
    )
  )
}