# Setup this project for Development

Clone this project to a local folder:

`git clone git@github.com:stats4sd/ukrainesurvey.git`
`cd ukrainesurvey`

## Create config file

Rename the file called `config.yml.exemple` into `config.yml`, and change the information in this file according to your own connection parameters. Note that this is a [YAML file](https://learnxinyminutes.com/docs/yaml/), so indentations and spaces are important!

Two 'blocks' are needed in the config file:
 - "mysql" -> containing details of the local mysql connection
 - "kobo" -> containing details of the kobotoolbox user account used to host the forms

R also requires a "default" block, even though we don't reference it in the code.

## Get Setup with R:

Requirements:
 - R Studio
 - Packrat

**process*:

1. Open the `ukraine tools.Rproj` in R Studio.
2. It will probably give a warning: "Packrat is not installed in the local library -- attempting to bootstrap an installation...". It may take a minute or so to load fully, but once you see the Files, Packages sidebar etc, you're ready to go.
3. run `packrat::restore()`. This will read the `packrat/packrat.lock` file and attempt to install the required packages locally. It will likely take several minutes.
4. You should then be able to run the app through RStudio!

## Setup Python
We use python to pull data from Kobotools into the database. (Using python instead of R as we already have these scripts and the methods to run them automatically server-side...).

1. Install Python3.7+
2. Run `pip3 install -r requirements.txt` to make sure you have all the packages needed.

## Setup Database
restore the database in Mysql/ukrainedb.sql to the database specified in yøur config.yml. This db dump contains all the tables, views and the initial state of the sampled clusters data.