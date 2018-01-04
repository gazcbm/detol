#!/bin/bash

#### Config Section ####
detol_reports="/home/gazcbm/detol/reports"
detol_home="/home/gazcbm/detol"
sublist3r_location="/pentest/intelligence-gathering/sublist3r"
aquatone_location="/home/gazcbm/aquatone"
altdns_location="/home/gazcbm/repo/altdns"
resolver_location="/home/gazcbm/go/bin"
dnsrecon_location="/pentest/intelligence-gathering/dnsrecon"

#### Verification Section ####
if [[ $# -eq 0 ]] ; then
    echo 'Missing domain'
    exit 0
fi

#### Main Program ####
host -t A utterbollocks.$@ > /dev/null 
if [[ $? -eq 0 ]] ; then 
  echo 'Wildcards in use - exiting'
  exit 0
fi
cd $detol_reports
mkdir $@
cd $@
echo -e "--\e[1m Starting Detol scan for \e[32m$@ \e[0m--"

echo -e "OSINT stage" 
echo -en "Testing for Zone transfer .... "
$dnsrecon_location/dnsrecon -t axfr -d $@ -j dnsrecon-axfr.txt
echo -e "Done"
echo -en "Running Aquatone .... "
aquatone-discover -d $@ > /dev/null
echo -e  "Done"
echo -en "Running Sublist3r .... "
python $sublist3r_location/sublist3r.py -o $detol_reports/$@/sublist3r-hosts.txt -d $@ > /dev/null
echo -e "Done"
echo -e "Results houskeeping stage"
cp $aquatone_location/$@/hosts.txt $detol_reports/$@/aquatone-hosts.txt
cat $detol_reports/$@/aquatone-hosts.txt | cut -d "," -f1 > $detol_reports/$@/hosts.tmp
cat $detol_reports/$@/sublist3r-hosts.txt >> $detol_reports/$@/hosts.tmp

echo -e "Fuzzing stage"
python $altdns_location/altdns.py -i $detol_reports/$@/hosts.tmp -w $altdns_location/words.txt -o $detol_reports/$@/fuzzhosts.tmp
cat $detol_reports/$@/hosts.tmp >> $detol_reports/$@/fuzzhosts.tmp
sort $detol_reports/$@/fuzzhosts.tmp | uniq > $detol_reports/$@/hosts.tmp

echo -e "Checking for online hosts"
cat $detol_reports/$@/hosts.tmp | $resolver_location/filter-resolved -c 100 > $detol_reports/$@/$@-domains.txt
$detol_home/tools/to_json.sh < $detol_reports/$@/$@-domains.txt > hosts.json
cp $detol_reports/$@/hosts.json $aquatone_location/$@/hosts.json
aquatone-scan -d $@
cp $aquatone_location/$@/urls.txt $detol_reports/$@/urls.txt
