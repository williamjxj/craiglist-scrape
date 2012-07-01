#!/bin/bash

export PATH=.:$PATH
JOB='cacraigslist.pl'
jobs='jobs'

cd $HOME/craig/

if [ $# -ne 1 ]; then
    echo "Which category to download ? 1:jobs; 2:services; 3:gigs"
	exit;
fi

$JOB -f | while read city
do
	$JOB -j "$jobs" -l | while read item
	do
		echo $JOB -j "$jobs" -c "$city" -i "$item"
		$JOB -j "$jobs" -c "$city" -i "$item"
	done
done

