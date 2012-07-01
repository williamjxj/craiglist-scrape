#!/bin/bash

cd $HOME/craig/

$HOME/craig/cajobs.pl -f | while read city
do
	$HOME/craig/cajobs.pl -c "$city" -i jobs
done
