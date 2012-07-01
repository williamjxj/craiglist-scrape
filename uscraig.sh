#!/bin/bash

export PATH=.:$PATH
JOB='uscraigslist.pl'
jobs='jobs'

cd $HOME/craig/

if [ $# -ne 1 ]; then
    echo "Which category to download ? 1:jobs; 2:services; 3:gigs"
	exit;
fi

if [ "$1" = '1' ];then
	jobs='jobs'
fi
if [ "$1" = '2' ];then
	jobs='services'	
fi
if [ "$1" = '3' ];then
	jobs='gigs'
fi
if [ "$1" = '4' ];then
	jobs='resumes'
fi

$JOB -f | while read city
do
	$JOB -j "$jobs" -l | while read item
	do
		echo $JOB -j "$jobs" -c "$city" -i "$item"
		$JOB -j "$jobs" -c "$city" -i "$item"
	done
done

if [ "$1" = '3' ];then
	$HOME/craig/mail.sh
fi

if [ "$1" = '4' ];then
	$HOME/craig/mail_resumes.sh
fi
