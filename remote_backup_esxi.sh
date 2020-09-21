#!/bin/bash
clear

# On récupère l'option -s (IP-DU-SERVEUR)
while getopts "s:i" OPTNAME
do
	 server=$OPTARG
done

# fichier temporaire où l'on écrit la liste VMs à sauvegarder (récupéré de l'ESXi)
loglist="/tmp/esxi-"$server"-list.txt"
# fichier Log temporaire de résultat de la sauvegarde
logfile="/tmp/esxi-"$server"-result.html"
error_general=0
msg=""
email="admin@benjaminformaticien.com"

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Récuperer les VMs qui sont retournées en SUCCESS
extractSuccessList()
{
	# On récupère les lignes où les machines sont en sucess
	line0num=$(sed -n '/info: Successfully completed backup for/=' $logfile)
	for x in $line0num
	do
		#On extrait les noms des VMs en SUCCESS
		line0=$(sed -n "$x"p $logfile)
		line0=$(echo $line0 | cut -c64- | sed s/#//g)
		line0="${line0//!/}"
		# On ajoute les VMs en success à l'array (tableau) $list_success
	  list_success+=($line0)
	done
}

# On vérifie si les VMs qui doivent être sauvegardées sont bien dans l'array $liste_success 0=ok 1=erreur
checkSuccess() {
	errors=0
	loglist=$(cat $loglist)
	for x in $loglist
	do
		containsElement $x "${list_success[@]}"
	  error=$?
		if [ $error = 0 ]
		then
			msg+="<tr bgcolor=\"green\"><td>$x </td><td> SUCCESS </td></tr>"
			#msg+="SUCESS $x \n"
		else
			#msg+="ERREUR !!! $x \n "
			msg+="<tr bgcolor=\"red\"><td>$x </td><td> ERREUR </td></tr>"
			let "error_general+=1"
		fi
	done
}

ConnectionESXi()
{
	# Récupérer la liste des VMs sauvegardées dans l'ESXi (sans les lignes commentées)
	ssh root@$server "grep ^[^#] $esxi_vms_list" > $loglist
	# Lancer le backup dans l'ESXi et écrire le log en local
	ssh root@$server "$esxi_ghetto_sh -f $esxi_vms_list" > $logfile
}

# Check si des erreurs sont rencontrés
finalCheck() {
  # On génère le message
  if [ $error_general -gt 0 ]
  then
  	result_general=$error_general" Erreur(s) lors de la sauvegarde"
  else
  	result_general="Sauvegarde effectuee avec succes"
  fi
}

sendMail() {
	# Sur le fichier de log on ajoute un <br> à la fin de chaque ligne pour le rendu du log par mail (html oblige)
	sed -i 's/$/<br>/' $logfile
	# On ajoute le tableau de résultat au début du fichier
	sed -i  "1i$result_general<br/><br/><table>$msg</table><br><br><br><br><br>Logs GhettoVCB :<br><br>" $logfile
	# On envoi le mail avec le avec le contenu du fichier
	grep -v "%" $logfile | mail -a "Content-type: text/html" -s "Sauvegarde ESXi $result_general" $email
	#grep ^[^%] /tmp/esxi-test-result.txt | /usr/sbin/sendmail yoann.humeau@crous-creteil.fr
  # Option invalide pour mail Debian -> -A $logfile
	cat $logfile
}

# Si l'ip renseignée est dans la liste, on effectue les taches, sinon on affiche un message d'erreur
case $server in
	192.168.0.1)
		# On déclare les chemins pour le script ghettoVCB.sh et vms_liste.conf (fichier contenant les noms des VMs)
	  	esxi_vms_list='/vmfs/volumes/datastoreX/ghettoVCB/liste_VM.conf'
	  	esxi_ghetto_sh='/vmfs/volumes/datastoreX/ghettoVCB/ghettoVCB.sh'
		ConnectionESXi
		extractSuccessList
		checkSuccess
		finalCheck
		sendMail
    		;;

  	*)
		msg="Option : -s "IP-DU-SERVEUR"
		Le serveur $server n'est pas dans la liste"
		;;
esac
