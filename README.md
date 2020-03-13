# Setup this project for Development / Testing

## 1. Clone this project to a local folder:

`git clone git@github.com:stats4sd/ukrainesurvey.git`
`cd ukrainesurvey`

## 2. Create config file

Copy the file `config.yml.exemple` into `config.yml`, and change the information in this file according to your own connection parameters. Note that this is a [YAML file](https://learnxinyminutes.com/docs/yaml/), so indentations and spaces are important!

Two 'blocks' are needed in the config file:
 - "mysql" -> containing details of the local mysql connection
 - "kobo" -> containing details of the kobotoolbox user account used to host the forms

R also requires a "default" block, even though we don't reference it in the code.

## 3. Get Setup with R:

1. Open the `ukraine tools.Rproj` in R Studio.
2. It will probably give a warning: "Packrat is not installed in the local library -- attempting to bootstrap an installation...". It may take a minute or so to load fully, but once you see the Files, Packages sidebar etc, you're ready to go.
3. run `packrat::restore()`. This will read the `packrat/packrat.lock` file and attempt to install the required packages locally. It will likely take several minutes.
4. You should then be able to run the app through RStudio!

## 4. Setup Python
We use python to pull data from Kobotools into the database and to generate fake data for testing. 

1. Install Python3.7+
2. Run `pip3 install -r requirements.txt` to make sure you have all the packages needed.

## 5. Setup Database
Restore the database in Mysql/ukrainedb.sql to the database specified in yøur config.yml:

`mysql -u {username} -p {database-name} < Mysql/ukrainedb.sql`

Then run the update_sql_views script to ensure you have the latest version of all MySQL Views:

`python3 deployement/update_sql_views.py`

## 6. Generate Fake Data for testing

**Generate buildings with dwellings within each cluster**
`python3 Data/building_generator.py`


You should now have a working platform where each cluster has a set of buildings and dwellings ready for sampling. 

