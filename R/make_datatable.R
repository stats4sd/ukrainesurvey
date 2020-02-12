####################################
# Make Datatable
#  @input df - a dataframe you want to render in the table
#  @returns - a datatable to put into an output property.
####################################
make_datatable <- function(df) {
  DT::renderDataTable({
    DT::datatable(
      df,
      filter = 'top',
      extensions = 'Buttons',
      options = list(
        dom = 'Blfrtip',
        buttons = c('copy', 'excel', 'pdf', 'print'),
        text = 'Download',
        br()
      ),
      class = "display"
    )
  })
}