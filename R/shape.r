library(geojsonR)
library(geojsonio)
library(rgdal)
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
writeLines(x, "shapes2.geojson")






y <- readLines(shapes_names[1])
y <- sub('\\]\\}$', '', x)
y2 <- sub('^\\{"type":"FeatureCollection","features":\\[', '', sub('\\]\\}$', '', y2))
y <- paste(y, y2, sep=",")

y <- paste0(y, "]}")
writeLines(y, "blub2.txt")