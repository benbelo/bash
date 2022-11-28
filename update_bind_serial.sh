#!/bin/bash

date=$(date +%Y%m%d%H)
file=/pathto/file.db
bottomserial=$(cat $file | grep Serial | awk '{print $1}')
topserial=$(cat $file | grep last | awk '{print $6}')

cp $file backup/

echo "Copying actual serial into old one"
sed -i "s/$topserial/$bottomserial/g" "$file"

echo "Updating new serial"
sed "10s/$bottomserial/$date/" file.db

echo "Serials were udpated for $file"
