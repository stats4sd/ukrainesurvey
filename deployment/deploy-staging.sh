#!/bin/bash

cd /var/www/ukraine-dev
git stash
git pull
R -e 'packrat::restore()'
pip3 install -r requirements.txt
python3 "deployement/update_sql_views.py"




