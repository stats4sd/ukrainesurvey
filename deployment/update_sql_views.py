import os
import yaml
import mysql.connector


dir_path = os.path.dirname(os.path.realpath(__file__))
wd = os.path.dirname(dir_path)

with open(os.path.join(wd,'config.yml')) as config_file:
    config = yaml.full_load(config_file);

sql_user = config['mysql']['user']
sql_pass = config['mysql']['password']
sql_db = config['mysql']['db']
sql_host = config['mysql']['host']

mydb = mysql.connector.connect(
                                   host=sql_host,
                                   user=sql_user,
                                   passwd=sql_pass,
                                   database=sql_db
                                   )

for filename in os.listdir(os.path.join(wd,'Mysql', 'views')):
  with open (os.path.join(wd,'Mysql', 'views', filename)) as file:
    query = file.read()
    name = filename.replace(".sql", "")
    
    sql = "CREATE OR REPLACE VIEW %s AS %s;" % (name, query)
    
    print(sql)
    
    mycursor = mydb.cursor()
    mycursor.execute(sql)
    mydb.commit()

