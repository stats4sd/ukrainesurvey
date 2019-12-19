# Setup this project for Development

Clone this project to a local folder:

`git clone git@github.com:stats4sd/ukrainesurvey.git`
`cd ukrainesurvey`

**add other laravel setup things**

## Get Setup with R:

Requirements:
 - R Studio
 - Packrat

**process*:

1. Open the `unhcr.Rproj` in R Studio.
2. It will probably give a warning: "Packrat is not installed in the local library -- attempting to bootstrap an installation...". It may take a minute or so to load fully, but once you see the Files, Packages sidebar etc, you're ready to go.
3. run `packrat::restore()`. This will read the `packrat/packrat.lock` file and attempt to install the required packages locally.
4. You should then be able to run the app through RStudio!

.conf.example
Note - The R Shiny app now requires the .env file, and will fail on database connection without it. (Copy the .env.example file to .env, and update the DB_ details if needed).