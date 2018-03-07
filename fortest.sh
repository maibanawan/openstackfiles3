#!/bin/bash -ex

export OS_TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "admin","domain": { "id": "default" },"password": "secret"}}},"scope": {"project": {"name": "admin","domain": { "id": "default" }}}}}' http://localhost/identity/v3/auth/tokens | awk '/X-Subject-Token/ {print $2}')
echo $OS_TOKEN
export RESP_JSON_ROUTERS=$(curl -s -X GET http://127.0.0.1:9696/v2.0/ports \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" | python -mjson.tool > ports.json)

x=1;
for i in `seq 0 8`
do
export port_router=$(cat ports.json | jq -r '.ports['$i'].device_owner')
echo $port_router
if [[ $port_router == network:router_interface ]] || [[ $port_router == network:router_gateway ]];
then
export port_$x_owner=$(cat ports.json | jq -r '.ports['$i'].device_owner')
export port_$x_id=$(cat ports.json | jq -r '.ports['$i'].id')
echo $port_$x_id
export port_$x_status=$(cat ports.json | jq -r '.ports['$i'].status')
x=$(( $x + 1 ))
echo $x
fi
done

