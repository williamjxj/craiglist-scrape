#!/bin/bash
# ft mcmurray
# peace river country
# kelowna / okanagan
#----------------------------------
# craigslist_category
# craigslist_city
# craigslist_country_state
# craigslist_item
# craigslist_topic 
#----------------------------------

# MYSQL="mysql -u craig -pwilliam -D craig"
# today=`date +'%y%m%d'`

cd $HOME/craig/

$HOME/craig/housing.pl -f | while read city
do
	$HOME/craig/housing.pl -c "$city" -i housing
done
