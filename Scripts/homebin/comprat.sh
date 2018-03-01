#!/bin/sh

showUsage() {
    echo "USAGE: $(basename "$0") [ARCHIVE]"
}

if [ $# -eq 0 -o $# -gt 1 ] || [ "$1" = '-h' -o "$1" = '--help' ]; then
    showUsage
    exit 1

elif ! [ -f "$1" ]; then
    echo "ERROR: File '${1}' doesn't exist"
    exit 2
fi

Numbers=$(echo "$(7z l "$1" | ag --nocolor '\s+(\d+)\s+(\d+).+? (files|file)($|,.+)')" |\
              perl -pe 's/.*?\s+(\d+)\s+(\d+).+? (files|file)($|,.+)/$1 $2/')


if [ -z "$Numbers" ]; then
    Numbers=$(echo "$(7z t "$1" | ag --nocolor '\s+(\d+)\s+(\d+).+? (files|file)($|,.+)')" |\
                  perl -pe 's/.*?\s+(\d+)\s+(\d+).+? (files|file)($|,.+)/$1 $2/')
fi


Num1=$(echo "$Numbers" | perl -pe 's/(\d+?)\s\d*/$1/')
Num2=$(echo "$Numbers" | perl -pe 's/\d+?\s(\d*)/$1/')

printf "\nActual size:     %10s\nCompressed size: %10s\n" "$Num1" "$Num2"

if [ "$(command -v python3)" ] || \
  ([ "$(command -v python)" ] && [ "$(python --version | ag '3\.\d\.\d')" ])
then
    PYCMD="python"
    [ "$(command -v python3)" ] && PYCMD="python3"
    $PYCMD -c "print(\"Compression ratio:\", ($Num2 / $Num1)*100, \"%\")"
else
    perl -e "\$x = ($Num2 / $Num1)*100; print \"Compression ratio: \"; print \$x; print \" %\n\""
fi
