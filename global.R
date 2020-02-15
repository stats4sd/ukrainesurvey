library(leaflet)
library(leaflet.extras)
library(dplyr)
library(shinydashboard)
library(rgdal)
library(qrcode)
library(plyr)
library(mapview)
library(rlist)


load("./Data/shapes.Rdata")

source('R/load_data.R')
source('R/sample_dwelllings.R')
source('R/make_datatable.R')

# initialise some variables
clusters <- load_clusters()
selected_cluster <- NULL