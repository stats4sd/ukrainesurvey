import requests
import json
import yaml
import mysql.connector
import os
from datetime import datetime, timedelta



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

def import_buildings():

    dir_path = os.path.dirname(os.path.realpath(__file__))
    wd = os.path.dirname(dir_path)

    print(dir_path)

    with open(os.path.join(wd, 'config.yml')) as config_file:
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
    # GET most recent submission_date from db
    #####################################
    mydb = mysql.connector.connect(
                                       host=sql_host,
                                       user=sql_user,
                                       passwd=sql_pass,
                                       database=sql_db
                                       )

    mycursor = mydb.cursor()

    sql = "SELECT submission_time from submissions order by submission_time desc limit 1";

    mycursor.execute(sql)
    latest_sub = mycursor.fetchone()
    filter_string = ""

    if latest_sub is not None:
        ## Minus 1 day as a quick way to ensure we are not missing any submissions with to-the-second identical timestamps.
        latest_sub = latest_sub[0]
        date_to_filter = latest_sub - timedelta(days=1)
        date_string = date_to_filter.strftime("%Y-%m-%dT%H:%M:%S")
        filter_string = '?query={"_submission_time":%%20{"$gt":"%s"}}' % (date_string)

    #####################################
    # GET data from Kobotools
    #####################################
    response = requests.get('%s/%s/data%s' % (data_url, form_uid, filter_string),
                            headers=headers,
                            auth=(kobo_user,kobo_pass)
                            );

    if response.status_code == 200:

        buildings = response.json()['results']


        print(len(buildings))

        #####################################
        # Insert into Submissions table
        #####################################
        sql_submissions = "INSERT INTO submissions (`id`, `uuid`, `form_id`, `version`, `start`, `end`, `today`, `submission_time`, `submitted_by`, `submission`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s) ON DUPLICATE KEY UPDATE id=id"

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
                     building['_submitted_by'] or "not-set",
                     json.dumps(building)
                     )
            val_submissions.append(entry)


        print(sql_submissions % val_submissions[0])
        ##print(val_submissions)

        mycursor.executemany(sql_submissions, val_submissions)

        mydb.commit()

        # #####################################
        # # Insert into Buildings table
        # #####################################
        sql_buildings = "INSERT INTO buildings (`id`, `cluster_id`, `structure_number`, `num_dwellings`, `latitude`, `longitude`, `altitude`, `precision`, `address`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) ON DUPLICATE KEY UPDATE id=id"

        for building in buildings:

            try:
                gps = building['gps'].split()

            except KeyError:
                ## FOR DEMO ONLY
                gps = [building['cheat/latitude'], building['cheat/longitude'], 0, 0]

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

            mycursor.execute(sql_buildings, (building_entry))
            mydb.commit()
            print(mycursor.rowcount, "buildings were inserted")
            # #####################################
            # # Generate Dwellings (Only if building was new)
            # #####################################

            if(mycursor.rowcount > 0):
                val_dwellings = []

                for x in range(1, int(building['number_dwellings'])+1):
                    dwelling_entry = (
                                      building['_id'],
                                      x
                                      )

                    val_dwellings.append(dwelling_entry)

                sql_dwellings = "INSERT INTO dwellings (`building_id`, `dwelling_number`) VALUES (%s, %s) ON DUPLICATE KEY UPDATE id=id"

                mycursor.executemany(sql_dwellings, val_dwellings)
                mydb.commit()
                print(mycursor.rowcount, "dwellings were inserted")

            ## End Dwellings insert
        ## End For buildings loop
    ## End if response is success
    else:
        print('Call to Kobotools returned status: %s' % response.status_code)

    return response.status_code

