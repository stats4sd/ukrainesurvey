#!/bin/bash

cd /var/www/ukraine-dev
git pull
R -e 'packrat::restore()'
pip3 install -r requirements.txt




