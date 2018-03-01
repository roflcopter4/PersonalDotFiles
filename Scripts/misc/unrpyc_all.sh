#!/bin/bash

IFS=$'\n'
file_array=( $(find) )

for file in ${file_array[@]}; do
    [[ -f "$file" ]] && [[ "$file" =~ '.rpyc' ]] && unrpyc "$file"
done
