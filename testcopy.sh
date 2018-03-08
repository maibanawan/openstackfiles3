#!/bin/bash -ex
#import json
export OS_TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "admin","domain": { "id": "default" },"password": "secret"}}},"scope": {"project": {"name": "admin","domain": { "id": "default" }}}}}' http://localhost/identity/v3/auth/tokens | awk '/X-Subject-Token/ {print $2}')
echo $OS_TOKEN
export PUBLIC_create=$(curl -s http://127.0.0.1:9696/v2.0/networks -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"network": {"name":"PUBLIC","provider:network_type":"flat","provider:physical_network":"public","router:external":"true"}}' | python -m json.tool > p.json)
export BLUE_create=$(curl -s http://127.0.0.1:9696/v2.0/networks -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"network": {"name":"BLUE"}}' | python -m json.tool > b.json)
export RED_create=$(curl -s http://127.0.0.1:9696/v2.0/networks -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"network": {"name":"RED"}}' | python -m json.tool > r.json)
export public=$(cat p.json | jq -r '.network.id')
export blue=$(cat b.json | jq -r '.network.id')
export red=$(cat r.json | jq -r '.network.id')
#bash test_red.sh $red
export PUBLIC_SUBNET=$(curl -s -X POST http://127.0.0.1:9696/v2.0/subnets \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" \
            -d "{
			\"subnet\": {
				\"network_id\": \"$public\",
				\"ip_version\": 4,
				\"name\": \"subnet-public\",
				\"cidr\": \"172.24.4.0/24\",
				\"enable_dhcp\": true,
				\"gateway_ip\": \"172.24.4.1\"
			}
		}" | python -m json.tool > psub.json)
export RESP_JSON_ROUTERS_CREATE=$(curl -s -X POST http://127.0.0.1:9696/v2.0/routers \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" \
	    -d "{
			\"router\": {
				\"external_gateway_info\": {
					\"network_id\": \"$public\"
				},
				\"name\": \"router-new\"
			}
		}" | python -m json.tool > rout.json)
export ext_gate=$(cat rout.json | jq -r '.router.external_gateway_info.external_fixed_ips[0].ip_address')
		
