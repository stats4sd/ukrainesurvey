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
        dom = 'Brt',
        buttons = c('excel', 'pdf'),
        text = 'Download',
        br()
      ),
      class = "display"
    )
  })
}

make_sample_datatable <- function(df) {
  DT::renderDataTable({
    DT::datatable(
      df,
      extensions = 'Buttons',
      options = list(
        columnDefs = list(
          list(targets = list(4,5,6,7,8),
              render = JS('function(data, type, row, meta) { return "<span style = \'padding-right: 50px;\'>[</span>]"}')
          #  render = JS('function(data, type, row, meta) { return "<input type=\'checkbox\'></input>" }')
          )
        ),
        dom = 'Brt',
        buttons = c('excel', 'pdf'),
        text = 'Download',
        br()
      ),
      class = "display"
    )
  })
}