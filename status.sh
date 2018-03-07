#!/bin/bash -ex
export RESP_JSON_NETWORKS=$(curl -s -X GET http://127.0.0.1:9696/v2.0/networks/$public \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" | python -m json.tool > public_status.json)
echo $RESP_JSON_NETWORKS
	    
