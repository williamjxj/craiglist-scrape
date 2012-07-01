#! /bin/bash
#uuu.sh $YESTERDAY >$HOME/craig/email.txt

email="$HOME/craig/email.txt"

cd $HOME/craig/

YESTERDAY=`date --date=yesterday +'%F'`
$HOME/craig/uuu.sh $YESTERDAY >$email

/usr/bin/mail -s "This is an auto generated email for craigslist data in $YESTERDAY." "kevin@alumni.sfu.ca,shawnleslie@gmail.com,jxjwilliam@gmail.com" < $email

