#!/bin/bash -ex
export OS_TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "admin","domain": { "id": "default" },"password": "secret"}}},"scope": {"project": {"name": "admin","domain": { "id": "default" }}}}}' http://localhost/identity/v3/auth/tokens | awk '/X-Subject-Token/ {print $2}')
echo $OS_TOKEN
export OS_TOKEN=${OS_TOKEN//$'\015'}		
HOST_ROUTES_AZ1={\"nexthop\":\"172.24.4.8\",\"destination\":\"10.0.0.0/24\"}
export ext_gate=$(cat rout.json | jq -r '.router.external_gateway_info.external_fixed_ips[0].ip_address')
export psubid=$(cat psub.json | jq -r '.subnet.id')	
export x=$(curl -k -X PUT "http://127.0.0.1:9696/v2.0/subnets/8981891e-9286-46b0-a07b-939994ba3575" -H "Content-Type: application/json" -H "X-Auth-Token: $OS_TOKEN" -d '{"subnet":{"host_routes":[{"destination":"0.0.0.0/0","nexthop":"172.24.4.9"}]}}')
