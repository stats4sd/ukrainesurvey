library(DBI)
library(DT)
library("readxl")
library(geojsonR)


#get shape from json file

#shape_json = rgdal::readOGR("C:/Users/LuciaFalcinelli/Dropbox (SSD)/ukraine tools/R/feature_collection1.geojson")
load("C:/Users/LuciaFalcinelli/Dropbox (SSD)/ukraine tools/R/shapes.Rdata")

##Create the connection with database 
con <- dbConnect(RMySQL::MySQL(),
                 dbname = "ukraine",
                 host ='127.0.0.1', 
                 port = 3306,
                 user = 'root',
                 password = "Logoslogos88"
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
