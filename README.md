# Setup this project for Development

Clone this project to a local folder:

`git clone git@github.com:stats4sd/ukrainesurvey.git`
`cd ukrainesurvey`

## Create config file

Rename the file called `config.yml.exemple` into `config.yml`, and change the information in this file according to your own connection parameters. Note that this is a [YAML file](https://learnxinyminutes.com/docs/yaml/), so indentations and spaces are important!

## Get Setup with R:

Requirements:
 - R Studio
 - Packrat

**process*:

1. Open the `ukraine tools.Rproj` in R Studio.
2. It will probably give a warning: "Packrat is not installed in the local library -- attempting to bootstrap an installation...". It may take a minute or so to load fully, but once you see the Files, Packages sidebar etc, you're ready to go.
3. run `packrat::restore()`. This will read the `packrat/packrat.lock` file and attempt to install the required packages locally. It will likely take several minutes.
4. You should then be able to run the app through RStudio!