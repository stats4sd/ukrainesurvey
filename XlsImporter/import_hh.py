import requests
import json
import yaml
import mysql.connector
import os
from datetime import datetime, timedelta

dir_path = os.path.dirname(os.path.realpath(__file__))
wd = os.path.dirname(dir_path)

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

def import_hh():
    with open(os.path.join(wd, 'config.yml')) as config_file:
        config = yaml.full_load(config_file);

    kobo_user = config['kobo']['user']
    kobo_pass = config['kobo']['password']
    sql_user = config['mysql']['user']
    sql_pass = config['mysql']['password']
    sql_db = config['mysql']['db']
    sql_host = config['mysql']['host']
    form_uid = config['kobo']['hh_form_uid']

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
    latest_sub = mycursor.fetchone()[0]

    ## Minus 1 day as a quick way to ensure we are not missing any submissions with to-the-second identical timestamps.
    date_to_filter = latest_sub - timedelta(days=1)
    filter_string = date_to_filter.strftime("%Y-%m-%dT%H:%M:%S")


    #####################################
    # GET data from Kobotools
    #####################################
    response = requests.get('%s/%s/data?query={"_submission_time":%%20{"$gt":"%s"}}' % (data_url, form_uid, filter_string),
                            headers=headers,
                            auth=(kobo_user,kobo_pass)
                            );

    if response.status_code == 200:

        submissions = response.json()['results']

        with open(os.path.join('Data','xls','hh_data.json'), '+w') as outfile:

            json.dump(submissions, outfile)

        print(len(submissions))

        #####################################
        # Insert into Submissions table
        #####################################
        sql_submissions = "INSERT INTO submissions (`id`, `uuid`, `form_id`, `version`, `start`, `end`, `today`, `submission_time`, `submitted_by`, `submission`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s) ON DUPLICATE KEY UPDATE id=id"

        val_submissions = []

        for submission in submissions:


            entry = (
                     submission['_id'],
                     submission['_uuid'],
                     submission['_xform_id_string'],
                     submission['__version__'],
                     to_mysql_date_time(submission['start']),
                     to_mysql_date_time(submission['end']),
                     submission['today'],
                     to_mysql_date_time(submission['_submission_time']),
                     submission['_submitted_by'] or "not-set",
                     json.dumps(submission)
                     )
            val_submissions.append(entry)


        print(sql_submissions % val_submissions[0])
        ##print(val_submissions)

        mycursor.executemany(sql_submissions, val_submissions)

        mydb.commit()


        ##IF the submission is not a duplicate:
        if(mycursor.rowcount > 0):

            # #####################################
            # # Insert into household_data table
            # #####################################

            for submission in submissions:

                sql_hh = "INSERT INTO household_data (`dwelling_id`, `submission_id`, `interview_status`) VALUES (%s, %s, %s)"

                household_entry = (
                         submission['location/dwelling_id'],
                         submission['_id'],
                         submission['cheat/survey_outcome'])

                mycursor.execute(sql_hh, (household_entry))
                mydb.commit()

                print(mycursor.rowcount, "hh_data record(s) was/were inserted")
                hh_id = mycursor.lastrowid
                # #####################################
                # # wra_data - add dummy submission
                # #####################################

                sql_wra = "INSERT INTO wra_data (`hh_id`) VALUES (%s)"
                wra_entry = (hh_id,)

                mycursor.execute(sql_wra, (wra_entry))
                mydb.commit()
                print(mycursor.rowcount, "wra record(s) was/were inserted")
                wra_id = mycursor.lastrowid

                # #####################################
                # # urine_samples - add dummy submission
                # #####################################

                sql_urine = "INSERT INTO urine_samples (`wra_id`) VALUES (%s)"
                urine_entry = (wra_id,)

                ## Add 2 samples if 2 are needed
                for x in range(1, int(submission['cheat/urine_samples'])+1):

                    mycursor.execute(sql_urine, (urine_entry))
                    mydb.commit()
                    print(mycursor.rowcount, "urine sample record(s) was/were inserted")


                # #####################################
                # # salt_samples - add dummy submission
                # #####################################

                if(submission['cheat/salt_samples'] == 1):
                    sql_salt = "INSERT INTO salt_samples (`hh_id`) VALUES (%s)"
                    salt_entry = (wra_id,)

                    mycursor.execute(sql_salt, salt_entry)
                    mydb.commit()
                    print(mycursor.rowcount, "salt sample record(s) was/were inserted")
                # End if submission includes salt sample
            # End foreach submission loop
        # End if submission is new
    ## End if response is success
    else:
        print('Call to Kobotools returned status: %s' % response.status_code)

    return response.status_code
