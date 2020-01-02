library(DBI)
library(rgdal)

source('./R/load_data.R')

#get shape and points from json file
shape_json = readOGR("Data/shapes.geojson")
point_json = readOGR("Data/points.geojson")

# filter to get only the districts we want - to be modified to put all the districts
shape_json <- subset(shape_json, name %in% clusters$electoral_id)
point_json <- subset(point_json, name %in% clusters$electoral_id)

# save as rdata for speed
save(shape_json, point_json, file="./Data/shapes.Rdata")
