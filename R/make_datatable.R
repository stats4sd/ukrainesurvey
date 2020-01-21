####################################
# Make Datatable
#  @input df - a dataframe you want to render in the table
#  @returns - a datatable to put into an output property.
####################################
make_datatable <- function(df) {
    DT::renderDataTable(
        DT::datatable(
          df,
          extensions = 'Buttons',
          filter = 'top',
          options = list(
            pageLength = 100,
            dom = 'Blfrtip',
            buttons = list(
              list(
                extend = "csv",
                text = "Download as CSV file"
              )
            )
          ),
        class = "display"
      )
    )
}