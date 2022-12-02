#!/bin/bash

date +%Y%m%d%H > date.txt

file=db.file
bottomserial=$(cat $file | grep Serial | awk '{print $1}')
topserial=$(cat $file | grep last | awk '{print $6}')
timestamp=$(cat date.txt)
temp=$bottomserialplusone


if [[ $bottomserial = $timestamp ]] && [[ $topserial = $bottomserial ]]; then
	echo "Serials are the same, adding 1 to the bottom serial"
	bottomserialplusone=$(awk "BEGIN {print $bottomserial + 1}")
		sed -i "10s/$bottomserial/$bottomserialplusone/g" "$file"

else

	cp $file backup/.

	echo "Copying actual serial into old one"
  		sed -i "s/$topserial/$bottomserial/g" "$file"

	echo "Updating new serial"
  		sed -i "10s/$bottomserial/$timestamp/" "$file"

	echo "Serials were udpated for $file"

fi


refreshbind="/usr/local/sbin/bind-refresh.sh"
restartbind="systemctl restart bind9"

echo "Restarting Bind9 in dns1"
	$restartbind && sleep 2 && systemctl status bind9 |grep ago

if [[ $(dig @localhost domain.com. |grep ANSWER: |awk '{print $10}' | cut -f1 -d ",") = "1" ]]; then

echo "Restarting Bind9 in dns3"
	ssh dns3 "$refreshbind && sleep 2 && systemctl status bind9 |grep ago"

echo "Restarting Bind9 in dns4"
	ssh dns4 "$refreshbind && sleep 2 && systemctl status bind9 |grep ago"

echo "Script terminated, if errors please look out"

fi
