#!/bin/bash

#### Config Section ####
detol_dir=""
sublist3r_location=""
aquatone_location=""
altdns_location=""
resolver_location=""

#### Verification Section ####
if [[ $# -eq 0 ]] ; then
    echo 'Missing domain'
    exit 0
fi

#### Main Program ####
cd $detol_dir
mkdir $@
cd $@
echo -e "--\e[1m Starting Detol scan for \e[32m$@ \e[0m--"

echo -e "OSINT stage" 
aquatone-discover -d $@
python $sublist3r_location/sublist3r.py -o $detol_dir/$@/sublist3r-hosts.txt -d $@

echo -e "Results houskeeping stage"
cp $aquatone_location/$@/hosts.txt $detol_dir/$@/aquatone-hosts.txt
cat $detol_dir/$@/aquatone-hosts.txt | cut -d "," -f1 > $detol_dir/$@/hosts.tmp
cat $detol_dir/$@/sublist3r-hosts.txt >> $detol_dir/$@/hosts.tmp

echo -e "Fuzzing stage"
python $altdns_location/altdns.py -i $detol_dir/$@/hosts.tmp -w $altdns_location/words.txt -o $detol_dir/$@/fuzzhosts.tmp
cat $detol_dir/$@/hosts.tmp >> $detol_dir/$@/fuzzhosts.tmp
sort $detol_dir/$@/fuzzhosts.tmp | uniq > $detol_dir/$@/hosts.tmp

echo -e "Checking for online hosts"
cat $detol_dir/$@/hosts.tmp | $resolver_location/filter-resolved -c 100 > $detol_dir/$@/$@-domains.txt
