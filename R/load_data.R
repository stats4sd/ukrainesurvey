library(DBI)
library(shinydashboard)
library(leaflet)
library(rgdal)

#get shape and points from json file
#shape_json = readOGR("Data/shapes.geojson")
#point_json = readOGR("Data/points.geojson")
#save(list(shape_json, point_json), file = "./Data/shapes.Rdata")
#load("./Data/points.Rdata")
load("./Data/shapes.Rdata")

# filter to get only the districts we want - to be modified to put all the districts
shape_json <- subset(shape_json, name %in% c(530621, 530538, 530333, 530633, 530950, 530330, 530934, 531188, 531189))
##Retrieve config parameters from the config.tml file
db_param <- config::get()

##Create the connection with database 
con <- dbConnect(RMySQL::MySQL(),
                 dbname = db_param$db,
                 host =db_param$host,
                 port = db_param$port,
                 user = db_param$user,
                 password = db_param$password
)


dbSendQuery(con,"SET NAMES utf8mb4")
#clusters table
clusters_table<-dbGetQuery(con,"SELECT * FROM clusters") # your query, normal
clusters_table$cluster_description<-as.character(clusters_table$cluster_description) #force variable to be of class character instead of factor
Encoding(clusters_table$cluster_description)<- "UTF-8" # say R the encoding should be UTF-8

#district table 
district_table<-dbGetQuery(con, "SELECT * FROM districts")
district_table$description_district_boundaries<-as.character(district_table$description_district_boundaries)
Encoding(district_table$description_district_boundaries)<- "UTF-8"

buildings_table<-dbGetQuery(con,'
  select *
  from buildings
  group by id
           ')

dbDisconnect(con)
