import requests
import json

# read in Kobotools credentials from a "config.json" file

with open('config.json') as config_file:
    config = json.load(config_file);

username = config['username']
password = config['password']


data_url = 'https://kf.kobotoolbox.org/api/v2/assets'


# Add the form id here
form_uid = config['form_uid']

headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}


response = requests.get('%s/%s/data' % (data_url,form_uid),
                        headers=headers,
                        auth=(username,password)
                        );

if response.status_code == 200:
    data = json.loads(response.content.decode('utf-8'))

    with open('form_data.json', '+w') as outfile:
        json.dump(data, outfile)

    print('Done. Json file created')

else:
    print('Call to Kobotools returned status: %s' % response.status_code)
