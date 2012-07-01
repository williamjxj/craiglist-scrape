#! /bin/bash

cd $HOME/scraper_logs/
find . -name "*.log" -mtime 2 -exec rm -f {} \;
