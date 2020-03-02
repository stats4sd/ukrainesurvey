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
                        "SELECT * FROM buildings_with_dwelling_counts
                        WHERE buildings_with_dwelling_counts.cluster_id = ", cluster_id, ";
                        "))
  
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

  # Hacky - I'm sure there's a cleaner way than this...
  
  if(nrow(dwellings) > 0) {
    dwellings$dwelling_text <- paste0("<h5>Dwelling No.: ", dwellings$dwelling_number,
                                      ifelse(dwellings$replacement==1," Replacement ",""),
                                      ifelse(dwellings$data_collected==1," Data Collected ",""))
  }
  else {
    dwellings$dwelling_text <- character(0)
  }
  
  drop_sql_connection(con)
  return(dwellings)
  
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
    
    # Save time by only writing the sampled and 10 replacements to the database. 
    if(
      sampled_dwellings[row, "sampled"] == TRUE 
      | ( sampled_dwellings[row, "replacement_order_number"] <= 10 & ! is.na(sampled_dwellings[row, "replacement_order_number"] ) )
      )  {
      
      # replace NA with "NULL" for SQL entry
      replacement_number <- ifelse(is.na(sampled_dwellings[row, "replacement_order_number"]),"NULL",sampled_dwellings[row, "replacement_order_number"] )
      
      sql <- paste("UPDATE dwellings 
                   SET sampled = ",
                   sampled_dwellings[row, "sampled"],
<<<<<<< HEAD
                   ", replacement_order_number = ",
                   replacement_number,
                   ", salt_needed = ",
                   sampled_dwellings[row, "salt_needed"],
=======
>>>>>>> dev-lucia
                   "WHERE dwellings.id = ",
                   sampled_dwellings[row, "dwelling_id"])
      

      results <- dbGetQuery(con, sql)
    }
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



drop_sql_connection <- function(con) {
  dbDisconnect(con)  
}




# Update the replacement_order_number column in dwellings table 

update_replacement <- function(replaced_dwellings) {
  
  con <- get_sql_connection()

  for (row in 1:nrow(replaced_dwellings)) {
    
    if(replaced_dwellings[row, "sampled"] == 0 | ( replaced_dwellings[row, "replacement_order_number"] <= 10 )) {
      
      # replace NA with "NULL" for SQL entry
      replacement_number <- ifelse(is.na(replaced_dwellings[row, "replacement_order_number"]),"NULL",replaced_dwellings[row, "replacement_order_number"] )
      
      sql <- paste("UPDATE dwellings 
                   SET replacement_order_number = ",
                   replacement_number,
                   "WHERE dwellings.id = ",
                   replaced_dwellings[row, "dwelling_id"])
      
      
      results <- dbGetQuery(con, sql)
    }
  }
  
  drop_sql_connection(con)
  
}
  

load_cluster_summary <- function() {
  
  con <- get_sql_connection()
  
  sql <- "SELECT * FROM cluster_summary"
  
  cluster_summary <- dbGetQuery(con,sql)
  drop_sql_connection(con)
  return(cluster_summary)
}


killDbConnections <- function () {
  
  all_cons <- dbListConnections(MySQL())
  
  print(all_cons)
  
  for(con in all_cons)
    +  dbDisconnect(con)
  
  print(paste(length(all_cons), " connections killed."))
  
}


