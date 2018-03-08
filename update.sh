#!/bin/bash -ex

export OS_TOKEN=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "admin","domain": { "id": "default" },"password": "secret"}}},"scope": {"project": {"name": "admin","domain": { "id": "default" }}}}}' http://localhost/identity/v3/auth/tokens | awk '/X-Subject-Token/ {print $2}')
echo $OS_TOKEN
HOST_ROUTES_AZ1={\”nexthop\”:\”$172.24.4.8\”,\”destination\”:\”10.0.0.0/24\”}
export x=$(curl -k -X PUT http://127.0.0.1:9696/v2.0/subnets/b5f13dd8-b273-46c0-9472-e31feb444b22\
         -H "X-Auth-Token: $OS_TOKEN"\
         -H "Content-Type: application/json"\ 
	 -d "{
			  \"subnet\": {
				     \"host_routes\": [
                                                  \"nexthop\":\"172.24.4.8\",
						  \"destination\":\"10.0.0.0/24\"
                                     ] 
			  }
	      }" | python -m json.tool)




