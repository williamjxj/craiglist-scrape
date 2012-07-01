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


echo ""
echo "-------------------"
echo ""


MYSQL="mysql -u kijiji -pwilliam -D kijiji"

echo "1. kijiji_item:"
$MYSQL <<"EOT"
select count(*) "TOTAL RECORDS: " from  kijiji_item; 
EOT

echo "2. kijiji_category:"
$MYSQL <<"EOT"
select count(*) "TOTAL RECORDS: " from  kijiji_category; 
EOT

# echo "3. kijiji_country_state:"
# $MYSQL <<"EOT"
# select count(*) "TOTAL RECORDS: " from  kijiji_country_state;
# EOT

echo "4. kijiji_city:"
$MYSQL <<"EOT"
select count(*) "TOTAL RECORDS: " from  kijiji_city;
EOT

echo "5. kijiji_topic:"
$MYSQL <<"EOT"
select count(*) "TOTAL RECORDS: " from  kijiji_topic; 
EOT

