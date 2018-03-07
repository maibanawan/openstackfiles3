#!/bin/bash -ex

export OS_TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "admin","domain": { "id": "default" },"password": "secret"}}},"scope": {"project": {"name": "admin","domain": { "id": "default" }}}}}' http://localhost/identity/v3/auth/tokens | awk '/X-Subject-Token/ {print $2}')
echo $OS_TOKEN
#jq 'del(.networks)' public_status.json
export RESP_JSON_NETWORKS=$(curl -s -X GET http://127.0.0.1:9696/v2.0/networks/ \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" | python -mjson.tool > network_status.json)
export net1_name=$(cat network_status.json | jq -r '.networks[0].name')
export net1_id=$(cat network_status.json | jq -r '.networks[0].id')
export net1_status=$(cat network_status.json | jq -r '.networks[0].status')	
export net2_name=$(cat network_status.json | jq -r '.networks[1].name')
export net2_id=$(cat network_status.json | jq -r '.networks[1].id')
export net2_status=$(cat network_status.json | jq -r '.networks[1].status')
export net3_name=$(cat network_status.json | jq -r '.networks[2].name')
export net3_id=$(cat network_status.json | jq -r '.networks[2].id')
export net3_status=$(cat network_status.json | jq -r '.networks[2].status')
export OS_TOKEN=${OS_TOKEN//$'\015'}
export RESP_JSON_SERVERS=$(curl -s -X GET http://127.0.0.1/compute/v2.1/servers \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" | python -mjson.tool > server_id.json)
export vm1_id=$(cat server_id.json | jq -r '.servers[0].id')
export vm2_id=$(cat server_id.json | jq -r '.servers[1].id')
export vm3_id=$(cat server_id.json | jq -r '.servers[2].id')

echo $vm1_id
export RESP_JSON_SERVERS=$(curl -s -X GET http://127.0.0.1/compute/v2.1/servers/$vm1_id \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" | python -mjson.tool > vm1.json)
export vm1_name=$(cat vm1.json | jq -r '.server.name')
export vm1_status=$(cat vm1.json | jq -r '.server.status')

export RESP_JSON_SERVERS=$(curl -s -X GET http://127.0.0.1/compute/v2.1/servers/$vm2_id \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" | python -mjson.tool > vm2.json)
export vm2_name=$(cat vm2.json | jq -r '.server.name')
export vm2_status=$(cat vm2.json | jq -r '.server.status')

export RESP_JSON_SERVERS=$(curl -s -X GET http://127.0.0.1/compute/v2.1/servers/$vm3_id \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" | python -mjson.tool > vm3.json)
export vm3_name=$(cat vm3.json | jq -r '.server.name')
export vm3_status=$(cat vm3.json | jq -r '.server.status')

export RESP_JSON_ROUTERS=$(curl -s -X GET http://127.0.0.1:9696/v2.0/ports \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" | python -mjson.tool > ports.json)

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
echo $port_$x_owner
export port_$x_id=$(cat ports.json | jq -r '.ports['$i'].id')
echo $port_$x_id
export port_$x_status=$(cat ports.json | jq -r '.ports['$i'].status')
echo $port_$x_status
x=$(( $x + 1 ))
echo $x
fi
done

cat <<EOF > myjson.json
{
    "Networks": 
        { 
	  { 
	    "Name":"$net1_name",
	    "ID":"$net1_id",
	    "status":"$net1_status"
	  },
	  {
	    "Name":"$net2_name",
	    "ID":"$net2_id",
	    "status":"$net2_status"
	  },
	  {
	    "Name":"$net3_name",
	    "ID":"$net3_id",
	    "status":"$net3_status"
	  }
	  
	},
    "Virtual machines": 
        {
	  {
	    "Name":"$vm1_name",
	    "ID":"$vm1_id",
	    "status":"$vm1_status"
	  },
	  {
	    "Name":"$vm2_name",
	    "ID":"$vm2_id",
	    "status":"$vm2_status"
	  },
	  {
	    "Name":"$vm3_name",
	    "ID":"$vm3_id",
	    "status":"$vm3_status"
	  }
	},	
    "interfaces": 
        {
	  {
	    "Port_owner":"$port_1_owner",
	    "ID":"$port_1_id",
	    "status":"$port_1_status"
	  },
	  {
	    "Port_owner":"$port_2_owner",
	    "ID":"$port_2_id",
	    "status":"$port_2_status
	  }'
	  {
	    "Port_owner":"$port_3_owner",
	    "ID":"$port_3_id",
	    "status":"$port_3_status
	  }
	}	
}
EOF



	    	    







	    
