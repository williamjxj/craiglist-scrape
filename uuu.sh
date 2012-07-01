#!/bin/bash

MYSQL="mysql -u craig -pwilliam -D craig"

if [ $# -ne 1 ]; then
    echo "What date to caculate ? like: 2010-06-16, or 2010-06-18."
    exit;
fi

date1=$1

$MYSQL <<- __EOT__

select count(distinct email) as "$date1's emails (USJOBS):" from craigslist_usjobs where date like  '$date1%';
select count(distinct email) as  "$date1's emails not @craigslist.org (USJOBS):"  from craigslist_usjobs where date like  '$date1%' and ( email !='' and email not like '%@craigslist.org%' );
select "";

select count(distinct email) as  "$date1's emails (USGIGS):"  from craigslist_usgigs where date like  '$date1%'; 
select count(distinct email) as  "$date1's emails  not @craigslist.org (USGIGS):"  from craigslist_usgigs where date like  '$date1%' and ( email !='' and email not like '%@craigslist.org%' );
select "";

select count(distinct email) as  "$date1's emails (USSERVICES):"  from craigslist_usservices  where date like  '$date1%';
select count(distinct email) as  "$date1's emails not @craigslist.org (USSERVICES):"  from craigslist_usservices  where date like  '$date1%' and ( email !='' and email not like '%@craigslist.org%' );
select "";

__EOT__

