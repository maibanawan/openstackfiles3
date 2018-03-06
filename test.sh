#!/bin/bash -ex
import json
export OS_TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "admin","domain": { "id": "default" },"password": "secret"}}},"scope": {"project": {"name": "admin","domain": { "id": "default" }}}}}' http://localhost/identity/v3/auth/tokens | awk '/X-Subject-Token/ {print $2}')
echo $OS_TOKEN
export BLUE_create=$(curl -s http://127.0.0.1:9696/v2.0/networks -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"network": {"name":"BLUE"}}' | python -m json.tool > b.json)
export RED_create=$(curl -s http://127.0.0.1:9696/v2.0/networks -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"network": {"name":"RED"}}' | python -m json.tool > r.json)
export blue=$(cat b.json | jq -r '.network.id')
export red=$(cat r.json | jq -r '.network.id')
#bash test_red.sh $red
export BLUE_SUBNET=$(curl -s -X POST http://127.0.0.1:9696/v2.0/subnets \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" \
	    -d "{
			\"subnet\": {
				\"network_id\": \"$blue\",
				\"ip_version\": 4,
				\"name\": \"subnet-blue\",
				\"cidr\": \"10.0.0.0/24\",
				\"enable_dhcp\": true,
				\"gateway_ip\": \"10.0.0.1\"
			}
		}")
export RED_SUBNET=$(curl -s -X POST http://127.0.0.1:9696/v2.0/subnets \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" \
	    -d "{
			\"subnet\": {
				\"network_id\": \"$red\",
				\"ip_version\": 4,
				\"name\": \"subnet-red\",
				\"cidr\": \"192.168.1.0/24\",
				\"enable_dhcp\": true,
				\"gateway_ip\": \"192.168.100.1\"
			}
		}")
		
curl -s http://127.0.0.1:9696/v2.0/routers -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"router":{"external_gateway_info":{"network_id":"7697d4c6-5b4c-4ea9-a1d6-af7d7f716f2b"},"name":"router-new"}}' | python -m json.tool		

#curl -s http://127.0.0.1:9696/v2.0/routers/5cd17bbd-5d01-4b71-94e0-67a064250873/add_router_interface -X PUT -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"subnet_id":"06e5b152-37f9-4591-8100-ce2061f081de"}' | python -m json.tool
