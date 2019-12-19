# was used to create the geojson shapes data file
setwd("~/Ukraine_shape_point_files")

shapes_points_names <- list.files()

shapes_names <- grep("_shape", shapes_points_names, value=TRUE)

x <- readLines(shapes_names[1])
x <- sub('\\]\\}$', '', x)

for(i in shapes_names[-1]){
  x2<-readLines(i)
  x2<- sub('^\\{"type":"FeatureCollection","features":\\[', '', sub('\\]\\}$', '', x2))
  x <- paste(x, x2, sep=",\n")
  #cat(sum(grepl("Point",x2)), "\t",i,"\n")
}

x <- paste0(x, "]}")
writeLines(x, "shapes.geojson")


