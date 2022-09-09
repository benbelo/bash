#!/bin/bash

usage=$(cat <<-END
	  	Syntax error : [search-ad.sh -X username] options below :
		-l <login> = mail info
		-g <mail> = login info from email
		-a <login> = pager
		-e <login> = account expiration
		-m <login> = employee ID
		-b <login> = room number
		-t <login> = phone and mobile
		-o <login> = OU
		-c <login> = when created
	END
	)

while getopts ":m:b:t:e:a:l:g:o:c:*:" option; do
    case "${option}" in
        l)
            l=${OPTARG}
		email=$(samba-tool user show $l |grep "mail" |awk '{print $2}')
		echo "$l - $email"
            ;;
        g)
            g=${OPTARG}
		login=$(ldbsearch -H /var/lib/samba/private/sam.ldb mail=$g |grep "sAMAccountName" |awk '{print $2}')
		echo "$login - $g"
            ;;
        a)
            a=${OPTARG}
		pager=$(samba-tool user show $a |grep "pager" |awk '{print $2}')
		login=$a
		echo "$login - $pager"
            ;;
        e)
            e=${OPTARG}
		expire=$(samba-tool user show $e |grep "accountExpires" |awk '{print $2}')
		status=$(samba-tool user show $e |grep "userAccountControl" |awk '{print $2}')
		login=$e
		echo "$login - $expire - $status"
	;;
        m)
            m=${OPTARG}
		employee=$(samba-tool user show $m |grep "employeeID" |awk '{print $2}')
		login=$m
		echo "$login - $employee"
	;;
        b)
            b=${OPTARG}
		bureau=$(samba-tool user show $b |grep "roomNumber" |awk '{print $2}')
		login=$b
		echo "$login - $bureau"
	;;
        t)
            t=${OPTARG}
		phone1="$(samba-tool user show $t |grep "telephoneNumber" |awk '{print $2}')"
		phone2="$(samba-tool user show $t |grep "mobile" |awk '{print $2}')"
		login=$t
		echo "$login - $phone1 - $phone2"
	;;
        o)
            o=${OPTARG}
                ou="$(samba-tool user show $o |grep "OU" |awk -F "=|," 'NR==1{print $4}')"
                login=$o
                echo "$login - $ou"
	;;
	c)
            c=${OPTARG}
                created="$(samba-tool user show $c |grep "whenCreated" |awk '{print substr($2, 1, length($2)-9)}')"
                login=$c
                echo "$login - $created"
        ;;
        *)
	        echo "$usage"
		exit 1
    esac
done

if [ $OPTIND -eq 1 ]; then echo "$usage";
fi
