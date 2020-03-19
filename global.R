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

clusters <- load_clusters()
clusters_list <- clusters$id