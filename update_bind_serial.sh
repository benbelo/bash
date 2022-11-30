#!/bin/bash

# copie le serial du bas a la place de celui du haut
# sed le serial du bas avec le timestamp actuel (YYYYMMDDHH)

date +%Y%m%d%H > date.txt

file=db.esiee
bottomserial=$(cat $file | grep Serial | awk '{print $1}')
topserial=$(cat $file | grep last | awk '{print $6}')
timestamp=$(cat date.txt)

if [[ $bottomserial = $date ]]; then
  echo "Serials are the same, please add 1 to the bottom serial"

else

  cp $file backup/.

  echo "Copying actual serial into old one"
  sed -i "s/$topserial/$bottomserial/g" "$file"

  echo "Updating new serial"
  sed -i "10s/$bottomserial/$timestamp/" "$file"

  echo "Serials were udpated for $file"

fi
