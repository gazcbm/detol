#!/bin/bash
function to_json() {
echo -en '"'${1}'":"'${2}'"'
}

echo -en '{'
COUNT=0
while read LINE
do
    [ "${COUNT}" -gt 0 ] && echo -en ','
    to_json $LINE
    : $((COUNT++))
done
echo -e '}'
