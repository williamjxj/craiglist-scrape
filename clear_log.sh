#! /bin/bash

cd $HOME/craig/logs/
s1=`date +'%y%m%d'`
s2=`expr $s1 - 3`
for i in `ls *$s2*.log 2>/dev/null`
do
	/bin/rm -f $i 2>/dev/null
done

cd $HOME/craig/logs/
find . -size 0 -mtime +1 -exec rm -f {} \;
