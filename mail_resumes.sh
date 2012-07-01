#! /bin/bash
#uuu.sh $YESTERDAY >$HOME/craig/email.txt

email="$HOME/craig/email_resumes.txt"

cd $HOME/craig/

#YESTERDAY=`date --date=today +'%F'`
YESTERDAY=`date --date=yesterday +'%F'`
uuu_resumes.sh $YESTERDAY >$email

/usr/bin/mail -s "This is an auto generated email for craigslist resumes section data in $YESTERDAY." "info@jasonwettstein.com,shawnleslie@gmail.com,jxjwilliam@gmail.com" < $email

