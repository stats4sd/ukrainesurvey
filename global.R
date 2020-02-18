library(leaflet)
library(leaflet.extras)
library(dplyr)
library(shinydashboard)
library(rgdal)
library(qrcode)
library(plyr)
library(mapview)
library(rlist)
library(shiny)
library(shinyjs)

load("./Data/shapes.Rdata")

source('R/load_data.R')
source('R/make_datatable.R')  
source('R/sample_dwellings.R')


# initialise some global variables
clusters <- load_clusters()
selected_region <- NULL
selected_cluster <- NULL
buildings <- NULL
dwellings <- NULL