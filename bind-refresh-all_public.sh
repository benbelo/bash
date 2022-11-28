#!/bin/bash

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
