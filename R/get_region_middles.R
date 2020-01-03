library(rgdal)

load("./Data/shapes.Rdata")

points = as.data.frame(point_json)

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

################ UPDATE VALUES IN DB ######################
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

for (i in 1:nrow(regions)) {
  dbSendQuery(con,
              paste0("UPDATE regions set `longitude` = ",longitude[i],", `latitude` = ", latitude[i], " WHERE id = ", regions$id[i], ";")
  )

}

dbDisconnect(con)

save(shape_json, point_json, regions, clusters, file="./Data/shapes.Rdata")
