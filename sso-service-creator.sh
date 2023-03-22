#!/bin/bash

read -p "Enter hostname: " hostname
read -p "Enter service description: " description

timestamp=$(date +%s)
filename="${hostname}-${timestamp}.json"
filepath="/etc/cas/services/${filename}"

echo "Creating file ${filepath}"

cat <<EOF > "${filepath}"
{
  "@class" : "org.apereo.cas.services.CasRegisteredService",
  "serviceId" : "^(http|https)://${hostname}.esiee.fr/.*",
  "name" : "${hostname}",
  "id" : "${timestamp}",
  "description" : "${description}",
  "evaluationOrder" : 1000,
  "attributeReleasePolicy" : {
    "@class" : "org.apereo.cas.services.ReturnAllAttributeReleasePolicy"
  }
}
EOF

echo "Done!"
