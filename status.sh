#!/bin/bash -ex

export OS_TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "admin","domain": { "id": "default" },"password": "secret"}}},"scope": {"project": {"name": "admin","domain": { "id": "default" }}}}}' http://localhost/identity/v3/auth/tokens | awk '/X-Subject-Token/ {print $2}')
echo $OS_TOKEN
#jq 'del(.networks)' public_status.json
export RESP_JSON_NETWORKS=$(curl -s -X GET http://127.0.0.1:9696/v2.0/networks/ \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" | python -mjson.tool > network_status.json)
export net1_name=$(cat network_status.json | jq -r '.networks[1].name')
export net1_id=$(cat network_status.json | jq -r '.networks[1].id')
export net1_status=$(cat network_status.json | jq -r '.networks[1].status')	
export net2_name=$(cat network_status.json | jq -r '.networks[2].name')
export net2_id=$(cat network_status.json | jq -r '.networks[2].id')
export net2_status=$(cat network_status.json | jq -r '.networks[2].status')
export net3_name=$(cat network_status.json | jq -r '.networks[3].name')
export net3_id=$(cat network_status.json | jq -r '.networks[3].id')
export net3_status=$(cat network_status.json | jq -r '.networks[3].status')
export OS_TOKEN=${OS_TOKEN//$'\015'}
export RESP_JSON_SERVERS=$(curl -s -X GET http://127.0.0.1/compute/v2.1/servers \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" | python -mjson.tool > server_status.json)
echo $RESP_JSON_SERVERS	    






	    
