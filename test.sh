#!/bin/bash
import json
export OS_TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "admin","domain": { "id": "default" },"password": "secret"}}},"scope": {"project": {"name": "admin","domain": { "id": "default" }}}}}' http://localhost/identity/v3/auth/tokens | awk '/X-Subject-Token/ {print $2}')
echo $OS_TOKEN
export BLUE_create=$(curl -s http://127.0.0.1:9696/v2.0/networks -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"network": {"name":"BLUE"}}' | python -m json.tool)
export RED_create=$(curl -s http://127.0.0.1:9696/v2.0/networks -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"network": {"name":"RED"}}' | python -m json.tool > r.json)
#export red=$(cat r.json | jq -r '.network.id')
export red=$(curl -s http://127.0.0.1:9696/v2.0/networks/{network_id} -X GET -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN")
echo $red
#export red_sub=$(curl -s http://127.0.0.1:9696/v2.0/subnets -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"subnet":{"name":"Subamp","cidr":"120.1.2.0/24","ip_version":4,"network_id":"$red"}}' | python -m json.tool)
