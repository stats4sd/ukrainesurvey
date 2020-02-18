library(DBI)
library(rgdal)

####################################
# PROCESS SHAPES 
# ## Run this script manually whenever clusters are added or removed from the database / sample frame.
####################################
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

#get shape and points from files
country_shape <- readr::read_file("./Data/ukraine.kml")
shape_json = readOGR("Data/shapes.geojson")
point_json = readOGR("Data/points.geojson")

# filter to get only the clusters we want
shape_json <- subset(shape_json, name %in% clusters$id)
point_json <- subset(point_json, name %in% clusters$id)

writeOGR(shape_json, "Data/shapes_filtered.geojson", driver="GeoJSON", layer="shapes")

writeOGR(point_json, "Data/points_filtered.geojson", driver="GeoJSON", layer="points")

regions_list <- setNames(regions$id,as.character(regions$name_en))


####################################
# Get "middle" of regions
#  - based on clusters in sample
####################################
points = as.data.frame(point_json)
points$name <- as.character(points$name)

latitude = list()
longitude = list()

for (i in 1:nrow(regions)) {
  
  filtered_clusters <- subset(clusters, region_id==regions$id[i])
  
  filtered_points <- subset(points, name %in% filtered_clusters$id)
  
  latitude[i] = mean(filtered_points$coords.x2) 
  longitude[i] = mean(filtered_points$coords.x1)
  
}

regions$latitude = latitude
regions$longitude = longitude

# UPDATE VALUES IN DB 
for (i in 1:nrow(regions)) {
  dbSendQuery(con,
              paste0("UPDATE regions set `longitude` = ",longitude[i],", `latitude` = ", latitude[i], " WHERE id = ", regions$id[i], ";")
  )
  
}


####################################
# Get Cluster Middles (using geopoints file)
####################################

names(points)[names(points)=="coords.x2"] <- "latitude"
names(points)[names(points)=="coords.x1"] <- "longitude"

drops <- names(points) %in% c("id")
points <- points[!drops] 

clusters <- merge(clusters, points, by.x="id", by.y="name")

db_param <- config::get(config='mysql')


for (i in 1:nrow(clusters)) {
  dbSendQuery(con,
              paste0("UPDATE clusters set `longitude` = ",clusters$longitude[i],", `latitude` = ", clusters$latitude[i], " WHERE id = ", clusters$id[i], ";")
  )
  
}

dbDisconnect(con)


save(shape_json, point_json, regions, regions_list, country_shape, file="./Data/shapes.Rdata")


# save as rdata for speed
save(shape_json, point_json, regions, regions_list, country_shape, file="./Data/shapes.Rdata")
