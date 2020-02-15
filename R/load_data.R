library(DBI)

get_sql_connection <- function() {
  
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
  
  dbSendQuery(con,"set character set 'utf8mb4'")
  
  return(con)
}

load_buildings <- function(cluster_id) {
  con <- get_sql_connection()

  buildings<-dbGetQuery(con, paste(
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
                        LEFT JOIN regions on regions.id = clusters.region_id
                        WHERE buildings.cluster_id = ", cluster_id, ";
                        "))
  
  buildings$region_name_en <- as.factor(buildings$region_name_en)
  buildings$region_name_uk <- as.factor(buildings$region_name_uk)
  buildings$cluster_id <- as.factor(buildings$cluster_id)  
  
  drop_sql_connection(con)
  return(buildings)
  
}

load_dwellings <- function(cluster_id) {
  
  con <- get_sql_connection()
  
  sql <- "SELECT
  dwellings.id as dwelling_id,
  dwellings.dwelling_number,
  dwellings.sampled,
  dwellings.replacement_order_number,
  dwellings.data_collected,
  dwellings.building_id,
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
  LEFT JOIN regions on regions.id = clusters.region_id"
  
  if(! is.null(cluster_id)) {
    sql <- paste(sql, "WHERE buildings.cluster_id = ", cluster_id)
  }
  
  dwellings <- dbGetQuery(con, sql)
  
  dwellings$region_name_en <- as.factor(dwellings$region_name_en)
  dwellings$region_name_uk <- as.factor(dwellings$region_name_uk)
  dwellings$cluster_id <- as.factor(dwellings$cluster_id)

  dwellings$dwelling_text <- paste0("<h5>Dwelling No.: ", dwellings$dwelling_number,
                                    ifelse(dwellings$replacement==1," Replacement ",""),
                                    ifelse(dwellings$data_collected==1," Data Collected ",""))
  
  dwellings_per_building <- dwellings %>% group_by(structure_number) %>%
    summarise(sum_sampled=sum(sampled), text=paste0(dwelling_text, "</h5>", collapse="\n"))
  
  combined = list("dwellings" = dwellings, "dwellings_per_building" = dwellings_per_building)
  
  drop_sql_connection(con)
  return(combined)
  
}

load_clusters <- function(region_id = NULL) {
  
  con <- get_sql_connection()
  
  sql <- "SELECT * FROM clusters_with_dwelling_counts"
  
  if(! is.null(region_id)) {
    sql <- paste(sql, "WHERE region_id = ", region_id)
  }

  clusters <- dbGetQuery(con,sql)
  drop_sql_connection(con)
  return(clusters)
}


#Update dwellings after the generate sample button has been clicked

update_dwellings <- function(sampled_dwellings) {
  
  con <- get_sql_connection()

  # update sampled dwellings  

  for (row in 1:nrow(sampled_dwellings)) {
    sql <- paste("UPDATE dwellings 
                 SET sampled = ",
                 sampled_dwellings[row, "sampled"],
                 ", replacement_order_number = ",
                 sampled_dwellings[row, "replacement.order"],
                 "WHERE dwellings.id = ",
                 sampled_dwellings[row, "dwelling_id"])
    
    results <- dbGetQuery(con, sql)
  }
  
  drop_sql_connection(con)
 
}

update_cluster <- function(cluster_id) {
 
  if(! is.null(cluster_id)) {
    con <- get_sql_connection()
    
    sql <- paste("UPDATE clusters
            SET sample_taken = 1 
            WHERE id = ", cluster_id)
    
    results <- dbGetQuery(con, sql)
  
    drop_sql_connection(con)
  }
}

#load summary cluster
load_summary_clusters <- function(cluster_id = NULL) {
  
  con <- get_sql_connection()
  
  sql <- "SELECT * FROM summary_cluster"
  
  if(! is.null(cluster_id)) {
    sql <- paste(sql, "WHERE cluster_id = ", cluster_id)
  }
  
  clusters <- dbGetQuery(con,sql)
  drop_sql_connection(con)
  return(clusters)
}

drop_sql_connection <- function(con) {
  dbDisconnect(con)  
}

killDbConnections <- function () {
  
  all_cons <- dbListConnections(MySQL())
  
  print(all_cons)
  
  for(con in all_cons)
    +  dbDisconnect(con)
  
  print(paste(length(all_cons), " connections killed."))
  
}


