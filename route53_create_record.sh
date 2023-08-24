#!/bin/bash

# Fetch the zone ID (in my case I only have one)
zone_id=$(aws route53 list-hosted-zones --query "HostedZones[0].Id" --output text)

# Prompt for the record type (only 3)
echo "Select the DNS record type you want to create:"
echo "1. A Record"
echo "2. CNAME Record"
echo "3. MX Record"
read -p "1, 2 or 3 ?: " record_type_choice

# Prompt for common record inputs
read -p "Enter the record name (e.g., example.com): " record_name
read -p "Enter the TTL (Time to Live) value: " ttl

case $record_type_choice in
    1)
        read -p "Enter the IPv4 address for the A record: " ipv4_address
        aws route53 change-resource-record-sets --hosted-zone-id "$zone_id" --change-batch "{
            \"Changes\": [
                {
                    \"Action\": \"CREATE\",
                    \"ResourceRecordSet\": {
                        \"Name\": \"$record_name\",
                        \"Type\": \"A\",
                        \"TTL\": $ttl,
                        \"ResourceRecords\": [{\"Value\": \"$ipv4_address\"}]
                    }
                }
            ]
        }"
        ;;
    2)
        read -p "Enter the target CNAME value: " cname_target
        aws route53 change-resource-record-sets --hosted-zone-id "$zone_id" --change-batch "{
            \"Changes\": [
                {
                    \"Action\": \"CREATE\",
                    \"ResourceRecordSet\": {
                        \"Name\": \"$record_name\",
                        \"Type\": \"CNAME\",
                        \"TTL\": $ttl,
                        \"ResourceRecords\": [{\"Value\": \"$cname_target\"}]
                    }
                }
            ]
        }"
        ;;
    3)
        read -p "Enter the mail server address: " mail_server
        read -p "Enter the priority for the MX record: " mx_priority
        aws route53 change-resource-record-sets --hosted-zone-id "$zone_id" --change-batch "{
            \"Changes\": [
                {
                    \"Action\": \"CREATE\",
                    \"ResourceRecordSet\": {
                        \"Name\": \"$record_name\",
                        \"Type\": \"MX\",
                        \"TTL\": $ttl,
                        \"ResourceRecords\": [{\"Value\": \"$mx_priority $mail_server\"}]
                    }
                }
            ]
        }"
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac
