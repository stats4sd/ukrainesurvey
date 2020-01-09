library(DBI)
library(shinydashboard)
library(leaflet)

load("./Data/shapes.Rdata")

country_shape <- readr::read_file("./Data/ukraine.kml")
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

buildings<-dbGetQuery(con,
    "SELECT
        regions.name_en as region_name_en,
        regions.name_uk as region_name_uk,
        buildings.cluster_id,
        buildings.structure_number,
        buildings.num_dwellings,
        buildings.latitude,
        buildings.longitude,
        buildings.altitude,
        buildings.precision,
        buildings.address
    FROM buildings
    LEFT JOIN clusters on clusters.id = buildings.cluster_id
    LEFT JOIN regions on regions.id = clusters.region_id;
    ")

buildings$region_name_en <- as.factor(buildings$region_name_en)
buildings$region_name_uk <- as.factor(buildings$region_name_uk)
buildings$cluster_id <- as.factor(buildings$cluster_id)


dwellings<-dbGetQuery(con,
    "SELECT
        dwellings.id as dwelling_id,
        dwellings.dwelling_number,
        dwellings.sampled,
        dwellings.replacement,
        dwellings.replacement_order_number,
        dwellings.data_collected,
        regions.name_en as region_name_en,
        regions.name_uk as region_name_uk,
        buildings.cluster_id,
        buildings.structure_number,
        buildings.num_dwellings,
        buildings.latitude,
        buildings.longitude,
        buildings.altitude,
        buildings.precision,
        buildings.address
        FROM buildings
        RIGHT JOIN dwellings on dwellings.building_id = buildings.id
        LEFT JOIN clusters on clusters.id = buildings.cluster_id
        LEFT JOIN regions on regions.id = clusters.region_id;
            ")

dwellings$region_name_en <- as.factor(dwellings$region_name_en)
dwellings$region_name_uk <- as.factor(dwellings$region_name_uk)
dwellings$cluster_id <- as.factor(dwellings$cluster_id)
dwellings$dwelling_id <- as.factor(dwellings$dwelling_id)


dbDisconnect(con)

