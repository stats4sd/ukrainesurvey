library(DBI)
library(shinydashboard)
library(leaflet)

#get shape from json file

#shape_json = rgdal::readOGR("Data/shapes.geojson")
#point_json = rgdal::readOGR("Data/points.geojson")
#save(list(shape_json, point_json), file = "./Data/shapes.Rdata")
#load("./Data/points.Rdata")
load("./Data/shapes.Rdata")

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
