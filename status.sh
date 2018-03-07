#!/bin/bash -ex
export OS_TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "admin","domain": { "id": "default" },"password": "secret"}}},"scope": {"project": {"name": "admin","domain": { "id": "default" }}}}}' http://localhost/identity/v3/auth/tokens | awk '/X-Subject-Token/ {print $2}')
echo $OS_TOKEN
#jq 'del(.networks)' public_status.json
export RESP_JSON_NETWORKS=$(curl -s -X GET http://127.0.0.1:9696/v2.0/networks/d1bef252-cfaf-4795-9fb6-01ced7350f7a \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" | python -mjson.tool > public_status.json)
export PUBLIC_status=$(cat public_status.json | jq -r '.networks.status')	
echo $PUBLIC_status

	    
