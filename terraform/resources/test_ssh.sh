#!/bin/bash
#shellcheck disable=SC2181
set -x

# Colors
DEFAULT="\e[0m"
GREEN="\e[32m"
RED="\e[31m"

ec2_url=$(terraform -chdir=../ output -json ipv4_address | jq -r '.[]')
http_endpoint=$(terraform -chdir=../ output -raw http_endpoint | awk -F':' '{print $1}')
PGUSER="appuser"
echo "Testing SSH..."
if [ "$1" == "--psql" ]; then
    #ssh -Tv ${PGUSER}@${http_endpoint} -p 5432
    psql -h ${http_endpoint} -U ${PGUSER} -p 5432 -d guest_book
fi 

ssh -q -i temp_key admin@"${ec2_url}" exit

if [ $? = 0 ]; then
    echo -e "${GREEN}Passed${DEFAULT}"
else
    echo -e "${RED}Failed.  Fix it.${DEFAULT}"
fi

#psql -h guest-book-database.c304ay0sspyp.us-east-1.rds.amazonaws.com -U appuser -p 5432 -d guest_book
