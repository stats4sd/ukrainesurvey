from geojson import Point, Feature, FeatureCollection, dump
import pycristoforo as pyc
from shapely.geometry import shape, MultiPolygon
import json
import random
import mysql.connector
import yaml
import os
import fnmatch

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

def generate_buildings():
    ## get the set of filtered cluster shapes
    with open("Data/shapes_filtered.geojson") as file:
      clusters = json.load(file)["features"]

    all_building_points = []



    for cluster in clusters:

        cluster_shape = MultiPolygon(shape(cluster["geometry"]))

        number = random.randrange(30, 250)

        ## generates random geopoints within the cluster's shape
        building_points = pyc.geoloc_generation(cluster_shape, number, cluster['properties']['name'])

        all_building_points.extend(building_points)

        ## add:
        # structure_number
        # num_dwellings random.randrange(1,50)
        # address lorem

        building_collection = FeatureCollection(building_points)

        ## export to file for importing into R
        filename = 'Data/test/buildings_cluster%s.geojson' % (cluster['properties']['name'])

        with open(filename, 'w') as file:
            dump(building_collection, file)

        print("%s buildings randomly placed within cluster with id %s" % (number, cluster['properties']['name']))



    all_buildings_collection = FeatureCollection(all_building_points)


    print("done!")

def save_buildings_to_db():

    test_dir = "Data/test"

    for root, dirnames, filenames in os.walk(test_dir):

        current_building = 1

        building_records = []
        dwelling_records = []

        mydb = getDbConnection()
        mycursor = mydb.cursor()

        for filename in fnmatch.filter(filenames, 'buildings_cluster*.geojson'):
            with open(test_dir + "/" + filename) as file:
                buildings = json.load(file)["features"]



            for building in buildings:

                # random number of dwellings
                num_dwellings = random.randrange(1,50)
                current_dwelling = 1

                # id, lat, long, cluster_id, structure number, dwelling number
                building_record = (
                    current_building,
                    building['geometry']['coordinates'][0],
                    building['geometry']['coordinates'][1],
                    building['properties']['country'],
                    building['properties']['point'],
                    num_dwellings,
                    )

                building_records.append(building_record)

                ## 1 new record for each dwelling
                for x in range(num_dwellings):

                    # building_id, dwelling_number
                    dwelling_record = (
                        current_building,
                        current_dwelling
                        )

                    dwelling_records.append(dwelling_record)
                    current_dwelling += 1

                current_building += 1


        sql = "INSERT INTO buildings (id, latitude, longitude, cluster_id, structure_number, num_dwellings) VALUES (%s, %s, %s, %s, %s, %s)"

        mycursor.executemany(sql, building_records)
        mydb.commit()

        print(mycursor.rowcount, "buildings were inserted into the database. Winning.")

        sql = "INSERT INTO dwellings (building_id, dwelling_number) VALUES (%s, %s)"

        mycursor.executemany(sql, dwelling_records)
        mydb.commit()

        print(mycursor.rowcount, "dwellings were inserted into the database. WOAH.")


save_buildings_to_db()

