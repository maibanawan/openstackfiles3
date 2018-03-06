#!/bin/bash -ex

if [ $# -lt 1 ]; then
	echo "Usage: $([ -z $BASH_ARGV ] && basename $0 || basename $BASH_ARGV) <network id>"
	exit 1
fi

export RESP_JSON_SUBNETS_CREATE=$(curl -s -X POST http://127.0.0.1:9696/v2.0/subnets \
            -H "Content-Type: application/json" \
            -H "X-Auth-Token: $OS_TOKEN" \
	    -d "{
			\"subnet\": {
				\"network_id\": \"$1\",
				\"ip_version\": 4,
				\"name\": \"subnet-$RANDOM\",
				\"cidr\": \"192.168.100.0/24\",
				\"enable_dhcp\": true,
				\"dns_nameservers\": [\"8.8.8.8\"],
				\"gateway_ip\": \"192.168.100.1\"
			}
		}")
