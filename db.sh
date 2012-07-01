#!/bin/bash
# $Id$

MYSQL="mysql -u craig -pwilliam -D craig"

echo "1. craigslist_item:"
$MYSQL <<"EOT"
select count(*) "TOTAL RECORDS: " from  craigslist_item; 
EOT

echo "2. craigslist_category:"
$MYSQL <<"EOT"
select count(*) "TOTAL RECORDS: " from  craigslist_category; 
EOT

echo "3. craigslist_country_state:"
$MYSQL <<"EOT"
select count(*) "TOTAL RECORDS: " from  craigslist_country_state;
EOT

echo "4. craigslist_city:"
$MYSQL <<"EOT"
select count(*) "TOTAL RECORDS: " from  craigslist_city;
EOT

echo "5. craigslist_topic:"
$MYSQL <<"EOT"
select count(*) "TOTAL RECORDS: " from  craigslist_topic; 
EOT

