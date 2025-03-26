#!/bin/bash

### Script rapide pour récupérer des VMs/CTs Proxmox et les comparer avec un fichier d'inventaire Ansible (et inversement)

rm cluster-vms.txt missing-from-ansible.txt missing-from-cluster.txt hosts

# Get infos du cluster avec pvesh
ssh root@yourproxmoxhere "pvesh get /cluster/resources | grep running | awk '{print \$26}'" > cluster-vms.txt
scp ansible@ansible:./hosts .

cluster_inventory="cluster-vms.txt"
ansible_inventory="hosts"

# Checks hosts présents dans Cluster mais pas dans inventaire Ansible
while IFS= read -r host; do
    if grep -qw "$host" "$ansible_inventory"; then
        echo "Host $host is present in the Ansible inventory."
    else
        echo "Host $host is missing in the Ansible inventory." >> "missing-from-ansible.txt"
    fi
done < "$cluster_inventory"

# Vérifier les hosts présents dans Ansible mais pas présents dans Proxmox -> Attention les groupes et commentaires seront affichés
while IFS= read -r inventory_host; do
    if ! grep -qw "$inventory_host" "$cluster_inventory"; then
	    echo "Host $inventory_host is present in the Ansible inventory but missing from the proxmox cluster." >> "missing-from-cluster.txt"
    fi
done < "$ansible_inventory"
