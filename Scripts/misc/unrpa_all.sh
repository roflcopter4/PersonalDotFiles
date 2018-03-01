#!/bin/dash

for file in *.rpa; do
    rpatool "$file" -x -o EXTRACTIONS
done
