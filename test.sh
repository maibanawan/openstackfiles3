#!/bin/bash -ex
#import json
export OS_TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "admin","domain": { "id": "default" },"password": "secret"}}},"scope": {"project": {"name": "admin","domain": { "id": "default" }}}}}' http://localhost/identity/v3/auth/tokens | awk '/X-Subject-Token/ {print $2}')
echo $OS_TOKEN
export PUBLIC_create=$(curl -s http://127.0.0.1:9696/v2.0/networks -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"network": {"name":"PUBLIC","provider:network_type": "flat","provider:physical_network": "public","shared":"true",}}' | python -m json.tool > p.json)
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
				\"name\": \"subnet-blue\",
				\"cidr\": \"172.24.4.0/24\",
				\"enable_dhcp\": true,
				\"gateway_ip\": \"172.24.4.1\"
			}
		}" | python -m json.tool > psub.json)
export psubid=$(cat psub.json | jq -r '.subnet.id')		
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
		}" | python -m json.tool > bsub.json)
export bsubid=$(cat bsub.json | jq -r '.subnet.id')	
echo $bsubid
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
				\"gateway_ip\": \"192.168.1.1\"
			}
		}" | python -m json.tool > rsub.json)
export rsubid=$(cat rsub.json | jq -r '.subnet.id')
echo $rsubid
curl -s http://127.0.0.1:9696/v2.0/routers -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"router":{"external_gateway_info":{"network_id":"$public"},"name":"router-new"}}' | python -m json.tool > rout.json		
export router=$(cat rout.json | jq -r '.router.id')
echo $router
export ADD_ROUTER_IF1=$(curl -s -X PUT http://127.0.0.1:9696/v2.0/routers/$router/add_router_interface \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" \
	    -d "{
			\"subnet_id\": \"$bsubid\"
		}")
export ADD_ROUTER_IF2=$(curl -s -X PUT http://127.0.0.1:9696/v2.0/routers/$router/add_router_interface \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" \
       	    -d "{
			\"subnet_id\": \"$rsubid\"
		}")	
export OS_TOKEN=${OS_TOKEN//$'\015'}		
#curl -s http://127.0.0.1:9696/v2.0/routers/$router/add_router_interface -X PUT -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"subnet_id":"$bsubid"}' | python -m json.tool
#server create --flavor m1.nano --image cirros-0.3.5-x86_64-disk --nic net-id=$red selfservice-instance
#export vmb=$(curl -g -i -X POST http://127.0.0.1/compute/v2/servers \
#-H "X-Auth-Token: $OS_TOKEN" \
#-H "Content-Type: application/json" \
#-d "{ 
#    	   \"server\": {
#	           \"name\": \"VM1\",
#	           \"imageRef\": \"aaab4dfd-8d9c-409e-a821-a0137e49e869\",
#		   \"flavorRef\": \"1\", 
#		   \"networks\": \"$blue\"
#	   }
#    }")

#curl -g -i -X POST http://localhost/compute/v2/servers -H "Accept: application/json"  -H "X-Auth-Token: $OS_TOKEN" -H "Content-Type: application/json" \
#-d "{
#      \"server\": {
#                    \"name\": \"test\",
#	            \"imageRef\": \"aaab4dfd-8d9c-409e-a821-a0137e49e869\",
#	            \"flavorRef\": \"5\",
#	            \"networks\": \"$blue\",
#	           }
#   }"
curl -X POST "http://127.0.0.1/compute/v2.1/servers" -H "Content-Type: application/json" -H "X-Auth-Token: $OS_TOKEN" -d "{\"server\":{\"name\":\"vm1\",\"imageRef\":\"aaab4dfd-8d9c-409e-a821-a0137e49e869\", \"flavorRef\":42, \"networks\": [{\"uuid\": \"$blue\"}]}}"
curl -X POST "http://127.0.0.1/compute/v2.1/servers" -H "Content-Type: application/json" -H "X-Auth-Token: $OS_TOKEN" -d "{\"server\":{\"name\":\"vm2\",\"imageRef\":\"aaab4dfd-8d9c-409e-a821-a0137e49e869\", \"flavorRef\":42, \"networks\": [{\"uuid\": \"$red\"}]}}"
curl -X POST "http://127.0.0.1/compute/v2.1/servers" -H "Content-Type: application/json" -H "X-Auth-Token: $OS_TOKEN" -d "{\"server\":{\"name\":\"vm3\",\"imageRef\":\"aaab4dfd-8d9c-409e-a821-a0137e49e869\", \"flavorRef\":42, \"networks\": [{\"uuid\": \"7697d4c6-5b4c-4ea9-a1d6-af7d7f716f2b\"}]}}"

#curl -X POST "http://172.0.0.1:8774/v1.1/5/os-security-group-rules" -H "X-Auth-Token: $OS_TOKEN" -H "Content-Type: application/json" -d "{\"security_group_rule\":{\"ip_protocol\":\"tcp\",\"from_port\":\"22\",\"to_port\":\"22\",\"cidr\":\"0.0.0.0/0\"}}" 
export RESP_JSON_SECURITY_GROUP_RULES_CREATE=$(curl -s -X POST http://127.0.0.1:9696/v2.0/security-group-rules \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" \
	    -d "{
			\"security_group_rule\": {
				\"security_group_id\": \"a40bda32-d2c8-4255-961a-952cca145ec3\",
				\"direction\": \"egress\",
				\"protocol\": \"tcp\",
				\"port_range_min\": \"22\",
				\"port_range_max\": \"22\",
				\"remote_ip_prefix\": \"0.0.0.0/0\",
				\"ethertype\": \"IPv4\"
			}
		}")

export RESP_JSON_SECURITY_GROUP_RULES_CREATE=$(curl -s -X POST http://127.0.0.1:9696/v2.0/security-group-rules \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" \
	    -d "{
			\"security_group_rule\": {
				\"security_group_id\": \"a40bda32-d2c8-4255-961a-952cca145ec3\",
				\"direction\": \"ingress\",
				\"protocol\": \"tcp\",
				\"port_range_min\": \"22\",
				\"port_range_max\": \"22\",
				\"remote_ip_prefix\": \"0.0.0.0/0\",
				\"ethertype\": \"IPv4\"
			}
		}")
