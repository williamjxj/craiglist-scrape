#!/bin/bash

cd $HOME/craig/

$HOME/craig/usjobs.pl -f | while read city
do
	$HOME/craig/usjobs.pl -c "$city" -i jobs
done
