#!/bin/bash

export AUTH=$(curl -i -H "Content-Type: application/json" -d '{ "auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "admin","domain": { "id": "default" },"password": "secret"}}},"scope": {"project": {"name": "admin","domain": { "id": "default" }}}}}' http://localhost/identity/v3/auth/tokens)
export OS_TOKEN=gAAAAABanorDguUB-Lk4bW_kYAdWPpZNZHYTQoBXXrCgz0z-HFor-bDKhalbAioxTKrgJ01fQYEViiQGahPyFr31aDwWgIfaLQGumhmo6TKq4wVW7yjZSTPXwRFEFf1idSD1q3__DfRves
#$(echo $AUTH) 
echo $OS_TOKEN
export BLUE_create=$(curl -s http://127.0.0.1:9696/v2.0/networks -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"network": {"name":"BLUE"}}' | python -m json.tool)
export RED_create=$(curl -s http://127.0.0.1:9696/v2.0/networks -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "X-Auth-Token:$OS_TOKEN" -d '{"network": {"name":"RED"}}' | python -m json.tool)
echo $1
