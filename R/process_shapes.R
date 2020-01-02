library(DBI)
library(rgdal)

# regions table
regions <-dbGetQuery(con,
                     "SELECT
                     regions.id,
                     regions.name_en,
                     regions.name_ru
                     FROM regions;")

#clusters table
clusters<-dbGetQuery(con,
                     "SELECT
                     clusters.id as id,
                     clusters.region_id as region_id,
                     regions.name_en as region_name_en,
                     regions.name_ru as region_name_ru,
                     clusters.electoral_id,
                     clusters.type,
                     clusters.locality_type,
                     clusters.num_voters,
                     clusters.smd_id
                     FROM clusters
                     LEFT JOIN regions on regions.id = clusters.region_id;
                     ") # your query, normal

clusters$region_name_en <- as.factor(clusters$region_name_en)
clusters$region_name_ru <- as.factor(clusters$region_name_ru)
clusters$type <- as.factor(clusters$type)
clusters$smd_id <- as.factor(clusters$smd_id)


#get shape and points from json file
shape_json = readOGR("Data/shapes.geojson")
point_json = readOGR("Data/points.geojson")

# filter to get only the districts we want - to be modified to put all the districts
shape_json <- subset(shape_json, name %in% clusters$electoral_id)
point_json <- subset(point_json, name %in% clusters$electoral_id)


# save as rdata for speed
save(shape_json, point_json, regions, clusters, file="./Data/shapes.Rdata")
