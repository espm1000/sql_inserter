#!/bin/bash

ec2_url=$(terraform -chdir=../ output -json ipv4_address | jq -r '.[]')
#http_endpoint=$(terraform -chdir=../ output -raw http_endpoint)
http_endpoint="guest-book-database.cl4yw4a8sbaz.us-east-1.rds.amazonaws.com"
PGUSER="appuser"
echo "Testing SSH..."
if [ $1 == "--psql" ]; then
    ssh -Tv ${PGUSER}@${http_endpoint} -p 5432
fi

ssh -q -i temp_key admin@"${ec2_url}" exit

if [ $? = 0 ]; then
    echo "Passed"
else
    echo "Failed.  Fix it."
fi

