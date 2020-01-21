library(DBI)
library(rgdal)

#Retrieve config parameters from the config.yml file
db_param <- config::get(config='mysql')

##Create the connection with database
con <- dbConnect(RMySQL::MySQL(),
                 dbname = db_param$db,
                 host =db_param$host,
                 port = db_param$port,
                 user = db_param$user,
                 password = db_param$password
)

dbSendQuery(con,"SET NAMES utf8mb4")

# regions table
regions <-dbReadTable(con,"regions")

#clusters table
clusters<-dbGetQuery(con,
                     "SELECT
                     clusters.id as id,
                     clusters.region_id as region_id,
                     regions.name_en as region_name_en,
                     regions.name_uk as region_name_uk,
                     clusters.sample_id,
                     clusters.type,
                     clusters.locality_type,
                     clusters.num_voters,
                     clusters.smd_id
                     FROM clusters
                     LEFT JOIN regions on regions.id = clusters.region_id;
                     ") # your query, normal

clusters$region_name_en <- as.factor(clusters$region_name_en)
clusters$region_name_uk <- as.factor(clusters$region_name_uk)
clusters$type <- as.factor(clusters$type)
clusters$smd_id <- as.factor(clusters$smd_id)

#get shape and points from json file
shape_json = readOGR("Data/shapes.geojson")
point_json = readOGR("Data/points.geojson")

# filter to get only the clusters we want - to be modified to put all the clusters
shape_json <- subset(shape_json, name %in% clusters$id)
point_json <- subset(point_json, name %in% clusters$id)

writeOGR(shape_json, "Data/shapes_filtered.geojson", driver="GeoJSON", layer="shapes")

writeOGR(point_json, "Data/points_filtered.geojson", driver="GeoJSON", layer="points")

regions_list <- setNames(regions$id,as.character(regions$name_en))

# save as rdata for speed
save(shape_json, point_json, regions, clusters, regions_list, file="./Data/shapes.Rdata")
