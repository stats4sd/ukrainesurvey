library(leaflet)
library(leaflet.extras)
library(shinydashboard)
library(rgdal)
library(qrcode)
library(plyr)
library(dplyr)
library(mapview)
library(rlist)
library(shiny)
library(shinyjs)
library(htmlwidgets)
library(shinycssloaders)


load("./Data/shapes.Rdata")

source('R/load_data.R')
source('R/make_datatable.R')  
source('R/sample_dwellings.R')

# initialise some global variables
clusters <- load_clusters()
cluster_summary <- load_cluster_summary()
district_summary <- load_district_summary()
oblast_summary <- load_oblast_summary()
national_summary <- load_national_summary()