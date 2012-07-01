#! /bin/bash

MYSQL="mysql -u craig -pwilliam -D craig"

if [ $# -ne 1 ]; then
    echo "What date to caculate ? like: 2010-06-16, or 2010-06-18."
    exit;
fi

date1=$1

$MYSQL <<- __EOT__
select min( date) "USJOBS: from $date1:"  from craigslist_usjobs where date like "$date1%";
select max( date) 'USJOBS: to $date1:'  from craigslist_usjobs where date like  '$date1%';
select "";
select min( date) 'USGIGS: from $date1:'  from craigslist_usgigs where date like  '$date1%';
select max( date) 'USGIGS: to $date1:'  from craigslist_usgigs where date like  '$date1%';
select "";
select min( date) 'USSERVICES: from $date1:'  from craigslist_usservices where date like  '$date1%';
select max( date) 'USSERVICES: to $date1:'  from craigslist_usservices where date like  '$date1%';
select "";
__EOT__

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

$MYSQL <<- __EOT__
select count(*) "USJOBS_EMAIL (not null) at $date1:" from craigslist_usjobs where date like  '$date1%' and email !='';
select count(*) "USGIGS_EMAIL (not null) at $date1:" from craigslist_usgigs where date like  '$date1%' and email !='';
select count(*) "USSERVICES_EMAIL (not null) at $date1:" from craigslist_usservices where date like  '$date1%' and email !='';
__EOT__

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
$MYSQL <<- __EOT__
select count(*) "USJOBS_EMAIL (not null, not @craigslist.org) at $date1:" from craigslist_usjobs where date like  '$date1%' and ( email !='' and email not like '%@craigslist.org%' );
select count(*) "USGIGS_EMAIL (not null, not @craigslist.org) at $date1:" from craigslist_usgigs where date like  '$date1%' and email !='' and email not like '%@craigslist.org';
select count(*) "USSERVICES_EMAIL (not null, not @craigslist.org) at $date1:" from craigslist_usservices where date like  '$date1%' and email !='' and email not like '%@craigslist.org';
__EOT__

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
$MYSQL <<- __EOT__
select count(distinct email) U_EMAIL_1 from craigslist_usjobs where date like  '$date1%' 
select count(distinct email) U_EMAIL_2 from craigslist_usjobs where date like  '$date1%' and ( email !='' and email not like '%@craigslist.org%' );

select count(distinct email) U_EMAIL_3 from craigslist_usgigs where date like  '$date1%' 
select count(distinct email) U_EMAIL_4 from craigslist_usgigs where date like  '$date1%' and ( email !='' and email not like '%@craigslist.org%' );

select count(distinct email) U_EMAIL_5 from craigslist_usservices  where date like  '$date1%'
select count(distinct email) U_EMAIL_6 from craigslist_usservices  where date like  '$date1%' and ( email !='' and email not like '%@craigslist.org%' );
__EOT__

