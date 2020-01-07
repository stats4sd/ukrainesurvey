library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Producing a Random Sample"),
   
   sidebarLayout(
    sidebarPanel(
      htmlOutput("text")
    ),
      mainPanel(
        tabsetPanel(
          tabPanel("Sample",
        numericInput("Max",
                     "Total number of entries in list:",
                     value=1000,
                     min = 1,
                     max = 30000),
        numericInput("Main",
                     "Total number of samples required for main list:",
                     value=100,
                     min = 1,
                     max = 1000),
        numericInput("Replacement",
                     "Total number of samples required for replacement list:",
                     value=100,
                     min = 1,
                     max = 1000),
        textInput("name",
                     "Please provide a name for this sample:",
                     value="mysampleframe"),
        downloadLink('downloadData', 'Download Sample Frame')),
        tabPanel("Instructions",
                 htmlOutput("instruct"))
        )
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  sampleframe<-  reactive({
  if(
    as.numeric(as.character(input$Main))>as.numeric(as.character(input$Max))|
    as.numeric(as.character(input$Replacement))>as.numeric(as.character(input$Max))  |
    (as.numeric(as.character(input$Main))+as.numeric(as.character(input$Replacement)))
    >as.numeric(as.character(input$Max))){
    stop("Sample size requested larger than total number of entries")
  }
  
  main<-sample(x = 1:as.numeric(as.character(input$Max)),
               replace = FALSE,
               size=as.numeric(as.character(input$Main)) )
  
  reduced<-(1:as.numeric(as.character(input$Max)))[-main]
  
  replacement<-sample(x = reduced,replace = FALSE,
                      size=as.numeric(as.character(input$Replacement)))
  
  
  
  sampleframe<-data.frame(ID=c(sort(main),replacement),
                          type=rep(c("main sample","replacement sample"),
                                   times=c(length(main),length(replacement))))
  sampleframe$replacement_order<-c(rep(0,length(main)),1:length(replacement))
  sampleframe
})
  
  output$downloadData <- downloadHandler(
    

filename = function() {
  paste(input$name,'-', Sys.Date(), '.csv', sep='')
},
   
    
    content = function(con) {
      write.csv(sampleframe(), con,row.names=FALSE)
    }
  )
  
output$text<-renderText(
  "Link to digital list Excel template: <a href=https://stats4sd.org/download/sample-frame-builder_2019-09-24_10:27:38/2019-10-01_17:21:40_digital-sample.xlsx/DIGITAL-SAMPLE.xlsx>here</a> <br>
  Link to paper list Excel template: <a href=https://stats4sd.org/download/sample-frame-builder_2019-09-24_10:27:38/2019-10-01_17:21:40_paper-sample.xlsx/PAPER-SAMPLE.xlsx>here</a><br>"
)
output$instruct<-renderText(
  '<b>Instructions (DIGITAL SAMPLE)</b><br>
 <br>1.	Extract a list of unique names or IDs and copy them into the spreadsheet, in the sheet "FULL LIST". Do not modify the first two columns of the sheet - copy the data starting from Column C. Save a copy of this Excel file as "[SAMPLE-NAME]-SAMPLE.XLSX". Ensure that there are no repetitions in this list and that there are no blank or missing rows. If the list provided requires removing out of scope entries, do this BEFORE copying into this Excel file, as it is essential that the numeric ID column in the first column of the tab "FULL LIST" is sequential
 <br>2.	If the information provided about each entry spans more than once column then please copy all of these columns after column C  of the sheet "FULL LIST", but try to ensure the most relevant identifiable column (name / unique ID code) is shown in column C.
 <br>3.	If the final ID number in column A does not match the expected total, please double-check all entries have been entered and then follow-up with the source of the information to ensure you have been provided with a complete, current and correct list of all applicable entries. 
 <br>4.	Access the sampling tool: https://shiny.stats4sd.org/randomsample/
 <br>5.	Enter the total number of entries (determined based on the number of rows in the sheet "FULL LIST". This is the number of units in the list from which you want to sample. Column A has already been pre-filled with numbers up to 6000, but you should trim or expand it to the size of your list of units)
 <br>6.	Enter the desired number of samples for the main sample, and the desired size for the replacement sample. The latter are additional units selected in case you need to replace any units from the original sample, for example in case of non-responses.
 <br>7.	Enter a name for the output file. If you are producing multiple samples from different lists it is reccomended to keep copies of the files produced for accountability.
 <br>8.	Open the output file. Then copy and paste the 3 columns in the output file from the sampling tool into the sheet "SAMPLE LIST". Details about the entries will then fill in within this sheet automatically, and the "In Sample" column from the FULL LIST sheet will update.
 <br>9.	You now have the randomly selected list of entries to include in your project.

 <br> <br> <br>

<b>Instructions (PAPER SAMPLE)</b><br>
 <br>1.	Collate all pages of the sample frame list. Clearly identify the page number in the top left corner of each page. If printing is double sided, label front and back separately.
 <br>2.	For each page count the number of entries listed on that page. Write the number clearly on the top-right hand corner of the page. Have two people independently complete this task to ensure the count is correct. If there is a dispute in the count between the two counters then both should recount together.
 <br>3.	Enter the details into the Excel template PAPER-SAMPLE.XLSX, in the sheet "FULL LIST". Column C should contain the page number and column D should contain the number of entries on the corresponding page number. Columns A and B, showing the cumulative totals at the start and end of each page should update automatically. Save a copy of this Excel file as "[SAMPLE-NAME]-SAMPLE.XLSX".
 <br>4.	If the final total in column B does not match the expected total, please double-check all pages have been entered and then follow-up with the source of the information to ensure you have been provided with a complete, current and correct list of all applicable entries.
 <br>5.	Access the sampling tool: https://shiny.stats4sd.org/randomsample/
 <br>6.	Enter the total number of entries (determined based on the final value in the End column - do not use a number provided which does not match the list you have)
 <br>7.	Enter the desired number of samples for the main sample, and the desired length for the replacement sample
 <br>8.	Enter a name for the output file. If you are producing multiple samples from different lists it is reccomended to keep copies of the files produced for accountability.
 <br>9.	Copy and paste the 3 columns in the output file from the sampling tool into the sheet "SAMPLE LIST". This will provide the page number and entry number within the page for the sampled workers, for both the main and replacement samples.
 <br>10a.	If you are permitted to, copy the information about the entries into the Excel file.
 <br>10b.	If you are not permitted to copy information, then use highlighter pens to indicate the sampled entries. Use different colours for the main sample, and the replacement sample. For the replacement sample also write in the order of replacement onto the lists.
 <br>11.	You now have the randomly selected list of entries to include in your project.

  
  '
)
}

# Run the application 
shinyApp(ui = ui, server = server)

