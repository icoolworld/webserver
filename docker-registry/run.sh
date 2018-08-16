#!/bin/bash

echo "start deploy docker-registry"

cd /data/webserver/docker-registry/

# ssl certs for docker registry,use self-signed certificate

host='192.168.50.128'

mkdir -p conf/certs && cd conf/
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -out certs/domain.crt -subj "/C=CN/ST=Beijing/L=Beijing/O=website Inc./OU=Web Security/CN=$host"
cd ../

# http support
touch /etc/docker/daemon.json
(
cat <<  EOF
{
  "registry-mirrors": ["https://registry.docker-cn.com"],
  "insecure-registries" : ["$host:5000"],
  "allow-nondistributable-artifacts": ["$host:5000"]
}
EOF
) > /etc/docker/daemon.json


#Restricting access Native basic auth

mkdir -p conf/auth
docker run  -it --rm  --entrypoint htpasswd   registry -Bbn testuser testpassword > conf/auth/htpasswd

docker-compose up -d
