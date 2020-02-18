import requests
import json
import yaml
import mysql.connector
from datetime import datetime

#####################################
# Method to convert Kobo's date-time strings into a MySQL-friendly date-time string.
#####################################
def to_mysql_date_time(string):
    try:
        string = datetime.strptime(string, '%Y-%m-%dT%H:%M:%S.%fZ')
    except ValueError:
        try:
            string = datetime.strptime(string, '%Y-%m-%dT%H:%M:%S')
        except ValueError:
            string = datetime.strptime(string, '%Y-%m-%dT%H:%M:%S.%f%z')

    return datetime.strftime(string, '%Y-%m-%d %H:%M:%S')

#####################################
# Get Config Details
#####################################

with open('../config.yml') as config_file:
    config = yaml.full_load(config_file);

kobo_user = config['kobo']['user']
kobo_pass = config['kobo']['password']
sql_user = config['mysql']['user']
sql_pass = config['mysql']['password']
sql_db = config['mysql']['db']
sql_host = config['mysql']['host']
form_uid = config['kobo']['building_form_uid']

data_url = 'https://kobo.humanitarianresponse.info/api/v2/assets'
headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}

#####################################
# GET data from Kobotools
#####################################
response = requests.get('%s/%s/data' % (data_url,form_uid),
                        headers=headers,
                        auth=(kobo_user,kobo_pass)
                        );

if response.status_code == 200:

    #####################################
    # temporarily load data from test-file instead of pulling from Kobo
    # data = json.loads(response.content.decode('utf-8'))
    #####################################
    with open('test-buildings.json') as test_file:
        data = json.load(test_file)
    #####################################

    with open('form_data.json', '+w') as outfile:

        json.dump(data, outfile)

    buildings = data['results']

    #####################################
    # Insert into Submissions table
    #####################################
    mydb = mysql.connector.connect(
                                   host=sql_host,
                                   user=sql_user,
                                   passwd=sql_pass,
                                   database=sql_db
                                   )

    mycursor = mydb.cursor()
    sql_submissions = "INSERT IGNORE INTO submissions (`id`, `uuid`, `form_id`, `version`, `start`, `end`, `today`, `submission_time`, `submitted_by`, `submission`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"

    val_submissions = []

    for building in buildings:
        entry = (
                 building['_id'],
                 building['_uuid'],
                 building['_xform_id_string'],
                 building['__version__'],
                 to_mysql_date_time(building['start']),
                 to_mysql_date_time(building['end']),
                 building['today'],
                 to_mysql_date_time(building['_submission_time']),
                 building['_submitted_by'],
                 json.dumps(building)
                 )
        val_submissions.append(entry)

    mycursor.executemany(sql_submissions, val_submissions)

    mydb.commit()

    # #####################################
    # # Insert into Buildings table
    # #####################################
    sql_buildings = "INSERT IGNORE INTO buildings (`id`, `cluster_id`, `structure_number`, `num_dwellings`, `latitude`, `longitude`, `altitude`, `precision`, `address`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"

    val_buildings = []
    val_dwellings = []

    for building in buildings:

        try:
            gps = building['gps'].split()

        except KeyError:
            gps = ["NULL","NULL","NULL","NULL"]

        building_entry = (
                 building['_id'],
                 building['cluster_id'],
                 building['structure_number'],
                 building['number_dwellings'],
                 gps[0],
                 gps[1],
                 gps[2],
                 gps[3],
                 building['address'])

        val_buildings.append(building_entry)

        for x in range(1, building['number_dwellings']):
            dwelling_entry = (
                              building['_id'],
                              x
                              )

            val_dwellings.append(dwelling_entry)

        sql_dwellings = "INSERT IGNORE INTO dwellings (`building_id`, `dwelling_number`) VALUES (%s, %s)"

    mycursor.executemany(sql_buildings, val_buildings)

    mydb.commit()
    print(mycursor.rowcount, "buildings were inserted")

    mycursor.executemany(sql_dwellings, val_dwellings)


    mydb.commit()
    print(mycursor.rowcount, "dwellings were inserted")



else:
    print('Call to Kobotools returned status: %s' % response.status_code)
