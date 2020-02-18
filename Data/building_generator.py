from geojson import Point, Feature, FeatureCollection, dump
import pycristoforo as pyc
from shapely.geometry import shape, MultiPolygon
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

def clean_buildings_db():

    mydb = getDbConnection()
    mycursor = mydb.cursor()

    sql_buildings = "delete from buildings;"

    # dwellings should be deleted through on delete CASCADE relationship
    mycursor.execute(sql_buildings)
    mydb.commit()

    shutil.rmtree('Data/test', ignore_errors=True)
    os.mkdir('Data/test')

def generate_buildings():
    ## get the set of filtered cluster shapes
    with open("Data/shapes_filtered.geojson") as file:
      clusters = json.load(file)["features"]

    all_building_points = []

    #clusters = clusters[1::2]


    for cluster in clusters:

        cluster_shape = MultiPolygon(shape(cluster["geometry"]))

        number = random.randrange(30, 100)

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
                num_dwellings = random.randrange(1,20)

                # id, lat, long, cluster_id, structure number, dwelling number
                building_record = (
                    current_building,
                    building['geometry']['coordinates'][1],
                    building['geometry']['coordinates'][0],
                    building['properties']['country'],
                    building['properties']['point'],
                    num_dwellings,
                    fake.address()
                    )

                building_records.append(building_record)

                ## 1 new record for each dwelling
                for x in range(1, num_dwellings):

                    # building_id, dwelling_number
                    dwelling_record = (
                        current_building,
                        x
                        )

                    dwelling_records.append(dwelling_record)

                current_building += 1


        sql = "INSERT INTO buildings (id, latitude, longitude, cluster_id, structure_number, num_dwellings, address) VALUES (%s, %s, %s, %s, %s, %s, %s)"

        mycursor.executemany(sql, building_records)
        mydb.commit()

        print(mycursor.rowcount, "buildings were inserted into the database. Winning.")

        sql = "INSERT INTO dwellings (building_id, dwelling_number) VALUES (%s, %s)"

        mycursor.executemany(sql, dwelling_records)
        mydb.commit()

        print(mycursor.rowcount, "dwellings were inserted into the database. WOAH.")


clean_buildings_db()
generate_buildings()
save_buildings_to_db()

