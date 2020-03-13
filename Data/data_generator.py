from geojson import Point, Feature, FeatureCollection, dump
from shapely.geometry import shape, MultiPolygon
import pycristoforo as pyc
import json
import random
import mysql.connector
import yaml
import os
import fnmatch
from faker import Faker
import shutil

fake = Faker()

def getDbConnection():

    #####################################
    # Get Config Details
    #####################################

    with open('config.yml') as config_file:
        config = yaml.full_load(config_file);

    sql_user = config['mysql']['user']
    sql_pass = config['mysql']['password']
    sql_db = config['mysql']['db']
    sql_host = config['mysql']['host']

    return mysql.connector.connect(
        host=sql_host,
        user=sql_user,
        passwd=sql_pass,
        database=sql_db
    )

#### Buildings and Dwellings are defined in the building generator. ###

# 1. Simulate 'take sample' for chosen cluster(s)


def sampleCluster():
  
  mydb = getDbConnection()
  mycursor = mydb.cursor()
  
  sql = "SELECT id FROM clusters where sample_taken = 0 limit 1;"
  
  mycursor.execute(sql)
  results = mycursor.fetchall()
  
  cluster_id = results[0][0]
  
  
  
  update_statement = "UPDATE clusters set sample_taken = 1 where id = %s"
  mycursor.execute(update_statement, (cluster_id) )
  
  print(cluster_id)

sampleCluster()
  
  

# 2. Generate 'submissions' -> insert into submissions
#
# 3. with dwelling_id -> update dwellings table:
#   - data_collected
#   - survey_success
#
# 4. insert into 'hh_data'
# 5. insert into salt_samples
# 6. insert into wra_data
# 7. insert into urine_samples
