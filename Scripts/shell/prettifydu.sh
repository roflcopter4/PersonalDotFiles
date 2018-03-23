#!/bin/sh

LANG=C

if [ -d "$1" ] || [ $# -eq 0 ]; then
    input="$(\du "$@" -d1 | sort -nr)"
else
    input="$(\du "$@" | sort -nr)"
fi
#input="$(\du -d1 | sort -nr)"

IFS='
'
NewString=''

longest=0
for line in $input; do
    byteStr="$(printf '%s' "$line" | perl -pe 's/^(\d+)\t.*/$1/')"

    while (printf '%s' "$byteStr" | grep -q '[0-9]\{4\}'); do
        line="$(printf '%s' "$line" | perl -pe 's/^(\d+?)(\d{3}(?:,|\s))(.*)/$1,$2$3/')"
        byteStr="$(printf '%s' "$line" | perl -pe 's/^([0-9,]+)\t.*/$1/')"
    done

    line="$(echo "$line" | perl -pe "s|${HOME}|~|")"

    if [ -z "$NewString" ]; then
        NewString="$line"
    else
        NewString="$(printf '%s\n%s' "$NewString" "$line")"
    fi

    strLen=${#byteStr}
    [ "$strLen" -gt "$longest" ] && longest=$strLen
done


#for line in $NewString; do
    #byteStr=$(printf "$line" | perl -pe 's/^([0-9,]+)\t.*/$1/')
    #strLen=${#byteStr}
    #if [ "$strLen" -lt "$longest" ]; then
        #dif=$(( $longest - $strLen ))
        #line=$(printf "$line" | perl -pe "s/^(.*)/(' ' x $dif) . \$1/e")
    #fi
    #echo "$line"
#done

for line in $NewString; do
    byteStr=$(printf '%s' "$line" | perl -pe 's/^([0-9,]+)\t.*/$1/')
    therest=$(printf '%s' "$line" | perl -pe 's/^[0-9,]+(\t.*)/$1/')
    printf '%*s%s\n' "${longest}" "$byteStr" "$therest"
done
