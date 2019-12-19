# was used to create the geojson points data file
setwd("~/Ukraine_shape_point_files")

shapes_points_names <- list.files()

points_names <- grep("_point", shapes_points_names, value=TRUE)

x <- readLines(points_names[1])
x <- sub('\\]\\}$', '', x)

for(i in points_names[-1]){
  x2<-readLines(i)
  x2<- sub('^\\{"type":"FeatureCollection","features":\\[', '', sub('\\]\\}$', '', x2))
  x <- paste(x, x2, sep=",\n")
  #cat(sum(grepl("Point",x2)), "\t",i,"\n")
}

x <- paste0(x, "]}")
writeLines(x, "points.geojson")

